import 'dart:async';

import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  final ExerciseRepository repository;

  StreamSubscription? _subscription;

  ExerciseCubit({required this.repository}) : super(ExerciseInitial());

  void loadExercises() {
    emit(ExerciseLoading());

    _subscription?.cancel();

    _subscription = repository.watchExercises().listen(
      (exercises) {
        emit(ExerciseLoaded(exercises: exercises));
      },
      onError: (error) {
        emit(ExerciseError(error.toString()));
      },
    );
  }

  Future<void> addExercise(ExerciseModel exercise) async {
    final currentState = state;

    if (currentState is ExerciseLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
      try {
        await repository.addExercise(exercise);
        emit(currentState.copyWith(isSubmitting: false));
      } catch (e) {
        emit(ExerciseError(e.toString()));
      }
    }
  }

  Future<void> updateExercise(ExerciseModel exercise) async {
    final currentState = state;

    if (currentState is ExerciseLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
      try {
        await repository.updateExercise(exercise);
        emit(currentState.copyWith(isSubmitting: false));
      } catch (e) {
        emit(ExerciseError(e.toString()));
      }
    }
  }

  Future<void> deleteExercise(String id) async {
    try {
      await repository.deleteExercise(id);
    } catch (e) {
      emit(ExerciseError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();

    return super.close();
  }
}
