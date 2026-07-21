import 'dart:async';

import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/program_exercise_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'program_exercise_state.dart';

class ProgramExerciseCubit extends Cubit<ProgramExerciseState> {
  final ProgramExerciseRepository repository;

  StreamSubscription? _subscription;

  ProgramExerciseCubit({required this.repository})
    : super(const ProgramExerciseInitial());

  void loadExercises(String programId) {
    emit(const ProgramExerciseLoading());

    _subscription?.cancel();

    _subscription = repository
        .watchProgramExercises(programId)
        .listen(
          (exercises) {
            emit(ProgramExerciseLoaded(exercises: exercises));
          },

          onError: (error) {
            emit(ProgramExerciseError(error.toString()));
          },
        );
  }

  Future<void> addExercise(ProgramExercise exercise) async {
    final current = state;

    if (current is ProgramExerciseLoaded) {
      emit(current.copyWith(isSubmitting: true));
    }

    try {
      await repository.addProgramExercise(exercise);
    } catch (e) {
      emit(ProgramExerciseError(e.toString()));
    }
  }

  Future<void> deleteExercise(String id) async {
    try {
      await repository.deleteProgramExercise(id);
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
