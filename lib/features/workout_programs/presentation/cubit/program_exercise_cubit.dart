import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/program_exercise_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'program_exercise_state.dart';

class ProgramExerciseCubit extends Cubit<ProgramExerciseState> {
  static const _unexpectedMessage =
      'خطای غیرمنتظره‌ای رخ داد. دوباره تلاش کنید.';

  final ProgramExerciseRepository repository;
  final AppLogger _logger;

  String? _workoutId;
  int _requestId = 0;

  ProgramExerciseCubit({required this.repository, required this._logger})
    : super(const ProgramExerciseInitial());

  /// This cubit is a per-flow factory instance, so an in-flight request can
  /// finish after the page (and the cubit) is gone.
  void _safeEmit(ProgramExerciseState state) {
    if (!isClosed) emit(state);
  }

  Future<void> loadExercises(String workoutId) async {
    _logger.debug('ProgramExerciseCubit: loading exercises for $workoutId');
    _workoutId = workoutId;
    final requestId = ++_requestId;

    _safeEmit(const ProgramExerciseLoading());

    try {
      final exercises = await repository.getProgramExercises(workoutId);
      if (requestId != _requestId) return; // superseded
      _logger.info(
        'ProgramExerciseCubit: exercises loaded (${exercises.length} items)',
      );
      _safeEmit(ProgramExerciseLoaded(exercises: exercises));
    } on AppException catch (e) {
      if (requestId != _requestId) return;
      _logger.error('ProgramExerciseCubit: load failed', error: e.message);
      _safeEmit(ProgramExerciseError(e.message));
    } catch (e) {
      if (requestId != _requestId) return;
      _logger.error('ProgramExerciseCubit: unexpected load error', error: e);
      _safeEmit(const ProgramExerciseError(_unexpectedMessage));
    }
  }

  /// Throws on failure; callers decide how to degrade.
  Future<void> _refreshExercises() async {
    final workoutId = _workoutId;
    if (workoutId == null) return;

    final requestId = ++_requestId;
    final exercises = await repository.getProgramExercises(workoutId);
    if (requestId != _requestId) return;
    _safeEmit(ProgramExerciseLoaded(exercises: exercises));
  }

  Future<bool> addProgramExercise(ProgramExercise exercise) => _mutate(
    action: 'add program exercise',
    run: () => repository.addProgramExercise(exercise),
  );

  Future<bool> updateProgramExercise(ProgramExercise exercise) => _mutate(
    action: 'update program exercise ${exercise.id}',
    run: () => repository.updateProgramExercise(exercise),
  );

  Future<bool> deleteExercise(String id) => _mutate(
    action: 'delete program exercise $id',
    run: () => repository.deleteProgramExercise(id),
  );

  Future<bool> reorderProgramExercise(String exerciseId, int targetOrder) =>
      _mutate(
        action: 'reorder program exercise $exerciseId',
        run: () => repository.reorderProgramExercise(exerciseId, targetOrder),
      );

  /// Shared mutation flow:
  ///  1. refuse if not loaded or another mutation is in flight,
  ///  2. run it; on failure restore the previous list (never switch to Error),
  ///  3. refresh; if only the refresh fails the mutation still counts as done.
  Future<bool> _mutate({
    required String action,
    required Future<void> Function() run,
  }) async {
    final current = state;

    if (current is! ProgramExerciseLoaded || current.isSubmitting) {
      _logger.warning(
        'ProgramExerciseCubit: cannot $action — not loaded or already submitting',
      );
      return false;
    }

    _safeEmit(
      ProgramExerciseLoaded(exercises: current.exercises, isSubmitting: true),
    );

    try {
      await run();
    } on AppException catch (e) {
      _logger.error(
        'ProgramExerciseCubit: failed to $action',
        error: e.message,
      );
      _restore(current);
      return false;
    } catch (e) {
      _logger.error(
        'ProgramExerciseCubit: unexpected error ($action)',
        error: e,
      );
      _restore(current);
      return false;
    }

    try {
      await _refreshExercises();
    } catch (e) {
      _logger.error(
        'ProgramExerciseCubit: refresh failed after $action',
        error: e,
      );
      _restore(current);
      return true;
    }

    return true;
  }

  void _restore(ProgramExerciseLoaded previous) {
    _safeEmit(ProgramExerciseLoaded(exercises: previous.exercises));
  }
}
