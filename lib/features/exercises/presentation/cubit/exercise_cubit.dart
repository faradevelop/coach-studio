import 'dart:async';

import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  final ExerciseRepository repository;
  final AppLogger _logger;

  StreamSubscription<List<Exercise>>? _subscription;

  ExerciseCubit({required this.repository, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger(),
      super(ExerciseInitial());

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to ExerciseCubit');
  }

  void loadExercises() {
    _logger.debug('ExerciseCubit: loading exercises');
    emit(ExerciseLoading());

    _subscription?.cancel();

    _subscription = repository.watchExercises().listen((exercises) {
      _logger.info(
        'ExerciseCubit: exercises loaded (${exercises.length} items)',
      );
      emit(ExerciseLoaded(exercises: exercises));
    }, onError: _handleError);
  }

  Future<bool> addExercise(Exercise exercise) async {
    _logger.info('ExerciseCubit: adding exercise');
    final currentState = state;

    if (currentState is! ExerciseLoaded) {
      _logger.warning(
        'ExerciseCubit: cannot add exercise — not in loaded state',
      );
      return false;
    }

    emit(currentState.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.addExercise(exercise);

      if (!success) {
        _logger.error('ExerciseCubit: failed to add exercise');
        _restoreState(currentState);
        return false;
      }
    } on AppException catch (e) {
      _logger.error('ExerciseCubit: error adding exercise', error: e.message);
      emit(ExerciseError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'ExerciseCubit: unexpected error adding exercise',
        error: e,
      );
      emit(ExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
      _logger.info('ExerciseCubit: exercise added successfully');
    } on AppException catch (e) {
      _logger.error(
        'ExerciseCubit: refresh failed after adding exercise',
        error: e.message,
      );
      emit(ExerciseError(e.message));
    } catch (_) {
      _logger.error('ExerciseCubit: refresh failed after adding exercise');
      emit(ExerciseError('Refresh failed!'));
    }

    return true;
  }

  Future<bool> updateExercise(Exercise exercise) async {
    _logger.info('ExerciseCubit: updating exercise ${exercise.id}');
    final currentState = state;

    if (currentState is! ExerciseLoaded) {
      _logger.warning(
        'ExerciseCubit: cannot update exercise — not in loaded state',
      );
      return false;
    }

    emit(currentState.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.updateExercise(exercise);

      if (!success) {
        _logger.error('ExerciseCubit: failed to update exercise');
        _restoreState(currentState);
        return false;
      }
    } on AppException catch (e) {
      _logger.error('ExerciseCubit: error updating exercise', error: e.message);
      emit(ExerciseError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'ExerciseCubit: unexpected error updating exercise',
        error: e,
      );
      emit(ExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
      _logger.info('ExerciseCubit: exercise updated successfully');
    } on AppException catch (e) {
      _logger.error(
        'ExerciseCubit: refresh failed after updating exercise',
        error: e.message,
      );
      emit(ExerciseError(e.message));
    } catch (_) {
      _logger.error('ExerciseCubit: refresh failed after updating exercise');
      emit(ExerciseError('Refresh failed!'));
    }

    return true;
  }

  Future<bool> deleteExercise(String id) async {
    _logger.info('ExerciseCubit: deleting exercise $id');
    final currentState = state;

    if (currentState is! ExerciseLoaded) {
      _logger.warning(
        'ExerciseCubit: cannot delete exercise — not in loaded state',
      );
      return false;
    }

    emit(currentState.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.deleteExercise(id);

      if (!success) {
        _logger.error('ExerciseCubit: failed to delete exercise');
        _restoreState(currentState);
        return false;
      }
    } on AppException catch (e) {
      _logger.error('ExerciseCubit: error deleting exercise', error: e.message);
      emit(ExerciseError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'ExerciseCubit: unexpected error deleting exercise',
        error: e,
      );
      emit(ExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
      _logger.info('ExerciseCubit: exercise deleted successfully');
    } on AppException catch (e) {
      _logger.error(
        'ExerciseCubit: refresh failed after deleting exercise',
        error: e.message,
      );
      emit(ExerciseError(e.message));
    } catch (_) {
      _logger.error('ExerciseCubit: refresh failed after deleting exercise');
      emit(ExerciseError('Refresh failed!'));
    }

    return true;
  }

  Future<void> _refreshExercises() async {
    final exercises = await repository.watchExercises().first;

    emit(ExerciseLoaded(exercises: exercises, isSubmitting: false));
  }

  void _restoreState(ExerciseLoaded previousState) {
    emit(previousState.copyWith(isSubmitting: false));
  }

  void _handleError(Object error) {
    if (error is AppException) {
      _logger.error(
        'ExerciseCubit: error in watch stream',
        error: error.message,
      );
      emit(ExerciseError(error.message));
      return;
    }

    _logger.error(
      'ExerciseCubit: unexpected error in watch stream',
      error: error,
    );
    emit(ExerciseError(error.toString()));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
