import 'dart:async';

import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutProgramCubit extends Cubit<WorkoutProgramState> {
  final WorkoutProgramRepository repository;
  final AppLogger _logger;

  StreamSubscription<List<WorkoutProgram>>? _subscription;

  WorkoutProgramCubit({required this.repository, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger(),
      super(WorkoutProgramInitial());

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to WorkoutProgramCubit');
  }

  void loadPrograms() {
    _logger.debug('WorkoutProgramCubit: loading programs');
    emit(WorkoutProgramLoading());

    _subscription?.cancel();

    _subscription = repository.watchPrograms().listen((programs) {
      _logger.info(
        'WorkoutProgramCubit: programs loaded (${programs.length} items)',
      );
      emit(WorkoutProgramLoaded(programs));
    }, onError: _handleError);
  }

  Future<void> _refreshPrograms() async {
    final programs = await repository.watchPrograms().first;

    emit(WorkoutProgramLoaded(programs));
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
    emit(WorkoutProgramInitial());
  }

  @override
  Future<void> close() {
    _subscription?.cancel();

    return super.close();
  }
}
