import 'dart:async';

import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/program_exercise_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'program_exercise_state.dart';

class ProgramExerciseCubit extends Cubit<ProgramExerciseState> {
  final ProgramExerciseRepository repository;
  final AppLogger _logger;

  StreamSubscription? _subscription;
  String? _workoutId;

  ProgramExerciseCubit({required this.repository, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger(),
      super(const ProgramExerciseInitial());

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to ProgramExerciseCubit');
  }

  void loadExercises(String workoutId) {
    _logger.debug(
      'ProgramExerciseCubit: loading exercises for program $workoutId',
    );
    _workoutId = workoutId;

    emit(const ProgramExerciseLoading());

    _subscription?.cancel();

    _subscription = repository.watchProgramExercises(workoutId).listen((
      exercises,
    ) {
      _logger.info(
        'ProgramExerciseCubit: exercises loaded (${exercises.length} items)',
      );
      emit(ProgramExerciseLoaded(exercises: exercises));
    }, onError: _handleError);
  }

  Future<void> _refreshExercises() async {
    final workoutId = _workoutId;

    if (workoutId == null) return;

    final exercises = await repository.watchProgramExercises(workoutId).first;

    emit(ProgramExerciseLoaded(exercises: exercises, isSubmitting: false));
  }

  Future<bool> addProgramExercise(ProgramExercise exercise) async {
    _logger.info('ProgramExerciseCubit: adding program exercise');
    final current = state;

    if (current is! ProgramExerciseLoaded) {
      _logger.warning(
        'ProgramExerciseCubit: cannot add exercise — not in loaded state',
      );
      return false;
    }

    emit(current.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.addProgramExercise(exercise);

      if (!success) {
        _logger.error('ProgramExerciseCubit: failed to add program exercise');
        _restoreState(current);
        return false;
      }
    } on AppException catch (e) {
      _logger.error(
        'ProgramExerciseCubit: error adding exercise',
        error: e.message,
      );
      emit(ProgramExerciseError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'ProgramExerciseCubit: unexpected error adding exercise',
        error: e,
      );
      emit(ProgramExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
      _logger.info('ProgramExerciseCubit: program exercise added successfully');
    } on AppException catch (e) {
      _logger.error(
        'ProgramExerciseCubit: refresh failed after adding exercise',
        error: e.message,
      );
      emit(ProgramExerciseError(e.message));
    } catch (e) {
      _logger.error(
        'ProgramExerciseCubit: refresh failed after adding exercise',
      );
      emit(ProgramExerciseError('Refresh failed!'));
    }

    return true;
  }

  Future<bool> updateProgramExercise(ProgramExercise exercise) async {
    _logger.info(
      'ProgramExerciseCubit: updating program exercise ${exercise.id}',
    );
    final current = state;

    if (current is! ProgramExerciseLoaded) {
      _logger.warning(
        'ProgramExerciseCubit: cannot update exercise — not in loaded state',
      );
      return false;
    }

    emit(current.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.updateProgramExercise(exercise);

      if (!success) {
        _logger.error(
          'ProgramExerciseCubit: failed to update program exercise',
        );
        _restoreState(current);
        return false;
      }
    } on AppException catch (e) {
      _logger.error(
        'ProgramExerciseCubit: error updating exercise',
        error: e.message,
      );
      emit(ProgramExerciseError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'ProgramExerciseCubit: unexpected error updating exercise',
        error: e,
      );
      emit(ProgramExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
      _logger.info(
        'ProgramExerciseCubit: program exercise updated successfully',
      );
    } on AppException catch (e) {
      _logger.error(
        'ProgramExerciseCubit: refresh failed after updating exercise',
        error: e.message,
      );
      emit(ProgramExerciseError(e.message));
    } catch (e) {
      _logger.error(
        'ProgramExerciseCubit: refresh failed after updating exercise',
      );
      emit(ProgramExerciseError('Refresh failed!'));
    }

    return true;
  }

  Future<bool> deleteExercise(String id) async {
    _logger.info('ProgramExerciseCubit: deleting program exercise $id');
    final current = state;

    if (current is! ProgramExerciseLoaded) {
      _logger.warning(
        'ProgramExerciseCubit: cannot delete exercise — not in loaded state',
      );
      return false;
    }

    emit(current.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.deleteProgramExercise(id);

      if (!success) {
        _logger.error(
          'ProgramExerciseCubit: failed to delete program exercise',
        );
        _restoreState(current);
        return false;
      }
    } on AppException catch (e) {
      _logger.error(
        'ProgramExerciseCubit: error deleting exercise',
        error: e.message,
      );
      emit(ProgramExerciseError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'ProgramExerciseCubit: unexpected error deleting exercise',
        error: e,
      );
      emit(ProgramExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
      _logger.info(
        'ProgramExerciseCubit: program exercise deleted successfully',
      );
    } on AppException catch (e) {
      _logger.error(
        'ProgramExerciseCubit: refresh failed after deleting exercise',
        error: e.message,
      );
      emit(ProgramExerciseError(e.message));
    } catch (e) {
      _logger.error(
        'ProgramExerciseCubit: refresh failed after deleting exercise',
      );
      emit(ProgramExerciseError('Refresh failed!'));
    }

    return true;
  }

  Future<bool> reorderProgramExercise(
    String exerciseId,
    int targetOrder,
  ) async {
    _logger.debug(
      'ProgramExerciseCubit: reordering exercise $exerciseId to order $targetOrder',
    );
    final current = state;

    if (current is! ProgramExerciseLoaded || current.isSubmitting) {
      _logger.warning(
        'ProgramExerciseCubit: cannot reorder exercise — invalid state',
      );
      return false;
    }

    emit(current.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.reorderProgramExercise(
        exerciseId,
        targetOrder,
      );

      if (!success) {
        _logger.error(
          'ProgramExerciseCubit: failed to reorder program exercise',
        );
        _restoreState(current);
        return false;
      }
    } on AppException catch (e) {
      _logger.error(
        'ProgramExerciseCubit: error reordering exercise',
        error: e.message,
      );
      emit(ProgramExerciseError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'ProgramExerciseCubit: unexpected error reordering exercise',
        error: e,
      );
      emit(ProgramExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
      _logger.debug(
        'ProgramExerciseCubit: program exercise reordered successfully',
      );
    } on AppException catch (e) {
      _logger.error(
        'ProgramExerciseCubit: refresh failed after reordering exercise',
        error: e.message,
      );
      emit(ProgramExerciseError(e.message));
    } catch (e) {
      _logger.error(
        'ProgramExerciseCubit: refresh failed after reordering exercise',
      );
      emit(ProgramExerciseError('Refresh failed!'));
    }

    return true;
  }

  void _restoreState(ProgramExerciseLoaded previousState) {
    emit(previousState.copyWith(isSubmitting: false));
  }

  void _handleError(Object error) {
    if (error is AppException) {
      _logger.error(
        'ProgramExerciseCubit: error in watch stream',
        error: error.message,
      );
      emit(ProgramExerciseError(error.message));
      return;
    }

    _logger.error(
      'ProgramExerciseCubit: unexpected error in watch stream',
      error: error,
    );
    emit(ProgramExerciseError(error.toString()));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
