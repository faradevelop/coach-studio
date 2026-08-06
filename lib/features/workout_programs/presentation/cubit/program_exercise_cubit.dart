import 'dart:async';

import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/program_exercise_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'program_exercise_state.dart';

class ProgramExerciseCubit extends Cubit<ProgramExerciseState> {
  final ProgramExerciseRepository repository;

  StreamSubscription? _subscription;
  String? _workoutId;

  ProgramExerciseCubit({required this.repository})
    : super(const ProgramExerciseInitial());

  void loadExercises(String workoutId) {
    _workoutId = workoutId;
    emit(const ProgramExerciseLoading());

    _subscription?.cancel();

    _subscription = repository
        .watchProgramExercises(workoutId)
        .listen(
          (exercises) {
            emit(ProgramExerciseLoaded(exercises: exercises));
          },

          onError: (error) {
            emit(ProgramExerciseError(error.toString()));
          },
        );
  }

  Future<void> _refreshExercises() async {
    final workoutId = _workoutId;
    if (workoutId == null) return;

    final exercises = await repository.watchProgramExercises(workoutId).first;
    emit(ProgramExerciseLoaded(exercises: exercises, isSubmitting: false));
  }

  Future<void> addProgramExercise(ProgramExercise exercise) async {
    final current = state;

    if (current is ProgramExerciseLoaded) {
      emit(current.copyWith(isSubmitting: true));
    }

    try {
      await repository.addProgramExercise(exercise);
      await _refreshExercises();
    } catch (e) {
      emit(ProgramExerciseError(e.toString()));
    }
  }

  Future<void> updateProgramExercise(ProgramExercise exercise) async {
    final current = state;

    if (current is ProgramExerciseLoaded) {
      emit(current.copyWith(isSubmitting: true));
    }

    try {
      await repository.updateProgramExercise(exercise);
      await _refreshExercises();
    } catch (e) {
      emit(ProgramExerciseError(e.toString()));
    }
  }

  Future<void> deleteExercise(String id) async {
    try {
      await repository.deleteProgramExercise(id);
      await _refreshExercises();
    } catch (e) {
      emit(ProgramExerciseError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();

    return super.close();
  }
}
