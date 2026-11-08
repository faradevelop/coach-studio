import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_filter.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutProgramCubit extends Cubit<WorkoutProgramState> {
  static const _unexpectedMessage =
      'خطای غیرمنتظره‌ای رخ داد. دوباره تلاش کنید.';

  final WorkoutProgramRepository repository;
  final AppLogger _logger;

  WorkoutProgramFilter _filter = const WorkoutProgramFilter();
  int _requestId = 0;

  WorkoutProgramCubit({required this.repository, required this._logger})
    : super(WorkoutProgramInitial());

  /// The currently applied filter (survives tab switches, cleared on reset()).
  WorkoutProgramFilter get filter => _filter;

  /// Always loads the full list; when a filter is active, also loads the
  /// filtered result (in parallel) so `programs` stays unfiltered.
  Future<WorkoutProgramLoaded> _fetch() async {
    final filter = _filter;
    final results = await Future.wait<List<WorkoutProgram>>([
      repository.getPrograms(),
      if (!filter.isEmpty) repository.getPrograms(filter: filter),
    ]);
    return WorkoutProgramLoaded(
      results[0],
      filtered: filter.isEmpty ? null : results[1],
    );
  }

  Future<void> loadPrograms() async {
    _logger.debug('WorkoutProgramCubit: loading programs');
    final requestId = ++_requestId;
    emit(WorkoutProgramLoading());

    try {
      final loaded = await _fetch();
      if (requestId != _requestId) return; // stale response
      _logger.info(
        'WorkoutProgramCubit: programs loaded (${loaded.programs.length} items)',
      );
      emit(loaded);
    } catch (e) {
      if (requestId != _requestId) return;
      _handleLoadError(e);
    }
  }

  /// Applies search / status / goal / level on the server. Returns false when
  /// the request failed (the caller shows the notification). Never replaces
  /// the list with an error state, so a failed search doesn't wipe the page.
  Future<bool> applyFilter(WorkoutProgramFilter filter) async {
    _filter = filter;

    final current = state;
    if (current is! WorkoutProgramLoaded) {
      await loadPrograms();
      return state is WorkoutProgramLoaded;
    }

    final requestId = ++_requestId;

    if (filter.isEmpty) {
      emit(WorkoutProgramLoaded(current.programs)); // no network needed
      return true;
    }

    try {
      final results = await repository.getPrograms(filter: filter);
      if (requestId != _requestId) return true; // superseded
      emit(WorkoutProgramLoaded(current.programs, filtered: results));
      return true;
    } catch (e) {
      if (requestId != _requestId) return true;
      _logger.error('WorkoutProgramCubit: failed to apply filter', error: e);
      return false;
    }
  }

  /// Throws on failure; callers decide how to degrade.
  Future<void> _refreshPrograms() async {
    final requestId = ++_requestId;
    final loaded = await _fetch();
    if (requestId != _requestId) return;
    emit(loaded);
  }

  Future<void> _refreshQuietly(String after) async {
    try {
      await _refreshPrograms();
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after $after',
        error: e,
      );
    }
  }

  // ───────────────────────── Program mutations ─────────────────────────

  Future<WorkoutProgram?> addProgram(WorkoutProgram program) async {
    _logger.info('WorkoutProgramCubit: adding program');

    final WorkoutProgram created;
    try {
      created = await repository.addProgram(program);
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: failed to add program',
        error: e.message,
      );
      return null;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error adding program',
        error: e,
      );
      return null;
    }

    await _refreshQuietly('adding program');
    return created;
  }

  Future<bool> updateProgram(WorkoutProgram program) => _mutateProgram(
    action: 'update program ${program.id}',
    run: () => repository.updateProgram(program),
  );

  Future<bool> deleteProgram(String id) => _mutateProgram(
    action: 'delete program $id',
    run: () => repository.deleteProgram(id),
  );

  Future<bool> duplicateProgram(String id, String title) => _mutateProgram(
    action: 'duplicate program $id',
    run: () => repository.duplicateProgram(id, title),
  );

  /// A failed mutation leaves the existing list untouched. A failed refresh
  /// after a successful mutation is only logged: the operation did succeed.
  Future<bool> _mutateProgram({
    required String action,
    required Future<void> Function() run,
  }) async {
    try {
      await run();
    } on AppException catch (e) {
      _logger.error('WorkoutProgramCubit: failed to $action', error: e.message);
      return false;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error ($action)',
        error: e,
      );
      return false;
    }

    await _refreshQuietly(action);
    return true;
  }

  // ─────────────────────────── Day mutations ───────────────────────────
  // Guarded by [WorkoutProgramLoaded.isSubmitting] so a second
  // Add/Delete/Reorder-day tap cannot fire while one is in flight.

  Future<bool> addDay(String programId) => _mutateDay(
    action: 'add day to program $programId',
    run: () => repository.addDay(programId),
  );

  /// The Backend cascades ProgramExercise deletion and shifts later days.
  Future<bool> deleteDay(String programId, int day) => _mutateDay(
    action: 'delete day $day of program $programId',
    run: () => repository.deleteDay(programId, day),
  );

  /// Moves [day] to the 1-based [targetOrder] position.
  Future<bool> reorderDay(String programId, int day, int targetOrder) =>
      _mutateDay(
        action: 'reorder day $day of program $programId to $targetOrder',
        run: () => repository.reorderDay(programId, day, targetOrder),
      );

  Future<bool> _mutateDay({
    required String action,
    required Future<Object?> Function() run,
  }) async {
    final current = state;

    if (current is! WorkoutProgramLoaded || current.isSubmitting) {
      _logger.warning(
        'WorkoutProgramCubit: cannot $action — not loaded or already submitting',
      );
      return false;
    }

    emit(current.copyWith(isSubmitting: true));

    try {
      await run();
    } on AppException catch (e) {
      _logger.error('WorkoutProgramCubit: failed to $action', error: e.message);
      _endSubmitting();
      return false;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error ($action)',
        error: e,
      );
      _endSubmitting();
      return false;
    }

    // Refresh — picks up the new daysPerWeek from the Backend. The day
    // operations change what the UI shows, so a failed refresh is reported
    // as a failure (same behaviour as before).
    try {
      await _refreshPrograms();
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after $action',
        error: e,
      );
      _endSubmitting();
      return false;
    }

    _endSubmitting(); // no-op unless the refresh was superseded
    return true;
  }

  /// Clears `isSubmitting` on the LATEST state (not a stale snapshot), and
  /// does nothing if the cubit was reset (logout) in the meantime.
  void _endSubmitting() {
    final s = state;
    if (s is WorkoutProgramLoaded && s.isSubmitting) {
      emit(s.copyWith(isSubmitting: false));
    }
  }

  void _handleLoadError(Object error) {
    if (error is AppException) {
      _logger.error('WorkoutProgramCubit: load failed', error: error.message);
      emit(WorkoutProgramError(error.message));
      return;
    }

    _logger.error('WorkoutProgramCubit: unexpected load error', error: error);
    emit(WorkoutProgramError(_unexpectedMessage));
  }

  void reset() {
    _requestId++;
    _filter = const WorkoutProgramFilter();
    emit(WorkoutProgramInitial());
  }
}
