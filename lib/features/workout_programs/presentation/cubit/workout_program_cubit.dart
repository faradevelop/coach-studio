import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_filter.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutProgramCubit extends Cubit<WorkoutProgramState> {
  final WorkoutProgramRepository repository;
  final AppLogger _logger;

  WorkoutProgramFilter _filter = const WorkoutProgramFilter();
  int _requestId = 0;

  WorkoutProgramCubit({required this.repository, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger(),
      super(WorkoutProgramInitial());

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to WorkoutProgramCubit');
  }

  /// The currently applied filter (survives tab switches, cleared on reset()).
  WorkoutProgramFilter get filter => _filter;

  /// Always loads the full list; when a filter is active, also loads the
  /// filtered result (in parallel) so `programs` stays unfiltered.
  Future<WorkoutProgramLoaded> _fetch() async {
    final filter = _filter;
    final results = await Future.wait<List<WorkoutProgram>>([
      repository.watchPrograms().first,
      if (!filter.isEmpty) repository.watchPrograms(filter: filter).first,
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
      _handleError(e);
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
      final results = await repository.watchPrograms(filter: filter).first;
      if (requestId != _requestId) return true; // superseded
      emit(WorkoutProgramLoaded(current.programs, filtered: results));
      return true;
    } catch (e) {
      if (requestId != _requestId) return true;
      _logger.error('WorkoutProgramCubit: failed to apply filter', error: e);
      return false;
    }
  }

  Future<void> _refreshPrograms() async {
    final requestId = ++_requestId;
    final loaded = await _fetch();
    if (requestId != _requestId) return;
    emit(loaded);
  }

  Future<WorkoutProgram?> addProgram(WorkoutProgram program) async {
    _logger.info('WorkoutProgramCubit: adding program');
    WorkoutProgram? createdProgram;

    // Mutation
    try {
      createdProgram = await repository.addProgram(program);

      if (createdProgram == null) {
        _logger.error('WorkoutProgramCubit: failed to add program');
        return null;
      }
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: error adding program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return null;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error adding program',
        error: e,
      );
      emit(WorkoutProgramError(e.toString()));
      return null;
    }

    // Refresh
    try {
      await _refreshPrograms();
      _logger.info('WorkoutProgramCubit: program added successfully');
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after adding program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
    } catch (_) {
      _logger.error('WorkoutProgramCubit: refresh failed after adding program');
      emit(WorkoutProgramError('Refresh Failed!'));
    }

    return createdProgram;
  }

  Future<bool> updateProgram(WorkoutProgram program) async {
    _logger.info('WorkoutProgramCubit: updating program ${program.id}');
    // Mutation
    try {
      final success = await repository.updateProgram(program);

      if (!success) {
        _logger.error('WorkoutProgramCubit: failed to update program');
        return false;
      }
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: error updating program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error updating program',
        error: e,
      );
      emit(WorkoutProgramError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshPrograms();
      _logger.info('WorkoutProgramCubit: program updated successfully');
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after updating program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
    } catch (_) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after updating program',
      );
      emit(WorkoutProgramError('Refresh Failed!'));
    }

    return true;
  }

  Future<bool> deleteProgram(String id) async {
    _logger.info('WorkoutProgramCubit: deleting program $id');
    // Mutation
    try {
      final success = await repository.deleteProgram(id);

      if (!success) {
        _logger.error('WorkoutProgramCubit: failed to delete program');
        return false;
      }
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: error deleting program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error deleting program',
        error: e,
      );
      emit(WorkoutProgramError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshPrograms();
      _logger.info('WorkoutProgramCubit: program deleted successfully');
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after deleting program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
    } catch (_) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after deleting program',
      );
      emit(WorkoutProgramError('Refresh Failed!'));
    }

    return true;
  }

  Future<bool> duplicateProgram(String id, String title) async {
    _logger.info('WorkoutProgramCubit: duplicating program $id');
    // Mutation
    try {
      final success = await repository.duplicateProgram(id, title);

      if (!success) {
        _logger.error('WorkoutProgramCubit: failed to duplicate program');
        return false;
      }
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: error duplicating program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error duplicating program',
        error: e,
      );
      emit(WorkoutProgramError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshPrograms();
      _logger.info('WorkoutProgramCubit: program duplicated successfully');
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after duplicating program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
    } catch (_) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after duplicating program',
      );
      emit(WorkoutProgramError('Refresh Failed!'));
    }

    return true;
  }

  /// Appends a new day. Guarded by [WorkoutProgramLoaded.isSubmitting] so a
  /// second Add/Delete/Reorder-day tap cannot fire while one is in flight.
  Future<bool> addDay(String programId) async {
    _logger.info('WorkoutProgramCubit: adding day to program $programId');
    final currentState = state;

    if (currentState is! WorkoutProgramLoaded || currentState.isSubmitting) {
      _logger.warning(
        'WorkoutProgramCubit: cannot add day — not loaded or already submitting',
      );
      return false;
    }

    emit(currentState.copyWith(isSubmitting: true));

    // Mutation
    try {
      final updated = await repository.addDay(programId);

      if (updated == null) {
        _logger.error('WorkoutProgramCubit: failed to add day');
        emit(currentState.copyWith(isSubmitting: false));
        return false;
      }
    } on AppException catch (e) {
      _logger.error('WorkoutProgramCubit: error adding day', error: e.message);
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error adding day',
        error: e,
      );
      emit(WorkoutProgramError(e.toString()));
      return false;
    }

    // Refresh — picks up the new daysPerWeek from the Backend.
    try {
      await _refreshPrograms();
      _logger.info('WorkoutProgramCubit: day added successfully');
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after adding day',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (_) {
      _logger.error('WorkoutProgramCubit: refresh failed after adding day');
      emit(WorkoutProgramError('Refresh Failed!'));
      return false;
    }

    return true;
  }

  /// Deletes [day] (the Backend cascades ProgramExercise deletion and
  /// shifts later days down). Guarded the same way as [addDay].
  Future<bool> deleteDay(String programId, int day) async {
    _logger.info(
      'WorkoutProgramCubit: deleting day $day of program $programId',
    );
    final currentState = state;

    if (currentState is! WorkoutProgramLoaded || currentState.isSubmitting) {
      _logger.warning(
        'WorkoutProgramCubit: cannot delete day — not loaded or already submitting',
      );
      return false;
    }

    emit(currentState.copyWith(isSubmitting: true));

    // Mutation
    try {
      final updated = await repository.deleteDay(programId, day);

      if (!updated) {
        _logger.error('WorkoutProgramCubit: failed to delete day');
        emit(currentState.copyWith(isSubmitting: false));
        return false;
      }
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: error deleting day',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error deleting day',
        error: e,
      );
      emit(WorkoutProgramError(e.toString()));
      return false;
    }

    // Refresh — picks up the new daysPerWeek from the Backend.
    try {
      await _refreshPrograms();
      _logger.info('WorkoutProgramCubit: day deleted successfully');
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after deleting day',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (_) {
      _logger.error('WorkoutProgramCubit: refresh failed after deleting day');
      emit(WorkoutProgramError('Refresh Failed!'));
      return false;
    }

    return true;
  }

  /// Moves [day] to the 1-based [targetOrder] position. Guarded the same
  /// way as [addDay]/[deleteDay].
  Future<bool> reorderDay(String programId, int day, int targetOrder) async {
    _logger.debug(
      'WorkoutProgramCubit: reordering day $day of program $programId to $targetOrder',
    );
    final currentState = state;

    if (currentState is! WorkoutProgramLoaded || currentState.isSubmitting) {
      _logger.warning(
        'WorkoutProgramCubit: cannot reorder day — not loaded or already submitting',
      );
      return false;
    }

    emit(currentState.copyWith(isSubmitting: true));

    // Mutation
    try {
      final updated = await repository.reorderDay(programId, day, targetOrder);

      if (!updated) {
        _logger.error('WorkoutProgramCubit: failed to reorder day');
        emit(currentState.copyWith(isSubmitting: false));
        return false;
      }
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: error reordering day',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error reordering day',
        error: e,
      );
      emit(WorkoutProgramError(e.toString()));
      return false;
    }

    // Refresh — not strictly required (daysPerWeek doesn't change), but
    // keeps `programs` consistent with the same pattern as every other
    // mutation here.
    try {
      await _refreshPrograms();
      _logger.debug('WorkoutProgramCubit: day reordered successfully');
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after reordering day',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (_) {
      _logger.error('WorkoutProgramCubit: refresh failed after reordering day');
      emit(WorkoutProgramError('Refresh Failed!'));
      return false;
    }

    return true;
  }

  void _handleError(Object error) {
    if (error is AppException) {
      _logger.error(
        'WorkoutProgramCubit: error in watch stream',
        error: error.message,
      );
      emit(WorkoutProgramError(error.message));
      return;
    }

    _logger.error(
      'WorkoutProgramCubit: unexpected error in watch stream',
      error: error,
    );
    emit(WorkoutProgramError(error.toString()));
  }

  void reset() {
    _requestId++;
    _filter = const WorkoutProgramFilter();
    emit(WorkoutProgramInitial());
  }
}
