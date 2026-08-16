import 'dart:async';

import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  final ExerciseRepository repository;

  StreamSubscription<List<Exercise>>? _subscription;

  ExerciseCubit({required this.repository}) : super(ExerciseInitial());

  void loadExercises() {
    emit(ExerciseLoading());

    _subscription?.cancel();

    _subscription = repository.watchExercises().listen((exercises) {
      emit(ExerciseLoaded(exercises: exercises));
    }, onError: _handleError);
  }

  Future<bool> addExercise(Exercise exercise) async {
    final currentState = state;

    if (currentState is! ExerciseLoaded) {
      return false;
    }

    emit(currentState.copyWith(isSubmitting: true));

    try {
      final success = await repository.addExercise(exercise);

      if (!success) {
        _restoreState(currentState);
        return false;
      }

      await _refreshExercises();

      return true;
    } on AppException catch (e) {
      emit(ExerciseError(e.message));
      return false;
    } catch (e) {
      emit(ExerciseError(e.toString()));
      return false;
    }
  }

  Future<bool> updateExercise(Exercise exercise) async {
    final currentState = state;

    if (currentState is! ExerciseLoaded) {
      return false;
    }

    emit(currentState.copyWith(isSubmitting: true));

    try {
      final success = await repository.updateExercise(exercise);

      if (!success) {
        _restoreState(currentState);
        return false;
      }

      await _refreshExercises();

      return true;
    } on AppException catch (e) {
      emit(ExerciseError(e.message));
      return false;
    } catch (e) {
      emit(ExerciseError(e.toString()));
      return false;
    }
  }

  Future<bool> deleteExercise(String id) async {
    final currentState = state;

    if (currentState is! ExerciseLoaded) {
      return false;
    }

    emit(currentState.copyWith(isSubmitting: true));

    try {
      final success = await repository.deleteExercise(id);

      if (!success) {
        _restoreState(currentState);
        return false;
      }

      await _refreshExercises();

      return true;
    } on AppException catch (e) {
      emit(ExerciseError(e.message));
      return false;
    } catch (e) {
      emit(ExerciseError(e.toString()));
      return false;
    }
  }

  Future<void> _refreshExercises() async {
    try {
      final exercises = await repository.watchExercises().first;

      emit(ExerciseLoaded(exercises: exercises, isSubmitting: false));
    } on AppException catch (e) {
      emit(ExerciseError(e.message));
    } catch (e) {
      emit(ExerciseError(e.toString()));
    }
  }

  void _restoreState(ExerciseLoaded previousState) {
    emit(previousState.copyWith(isSubmitting: false));
  }

  void _handleError(Object error) {
    if (error is AppException) {
      emit(ExerciseError(error.message));
      return;
    }

    emit(ExerciseError(error.toString()));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
