import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';

sealed class ProgramExerciseState {
  const ProgramExerciseState();
}

class ProgramExerciseInitial extends ProgramExerciseState {
  const ProgramExerciseInitial();
}

class ProgramExerciseLoading extends ProgramExerciseState {
  const ProgramExerciseLoading();
}

class ProgramExerciseLoaded extends ProgramExerciseState {
  final List<ProgramExercise> exercises;

  final bool isSubmitting;

  const ProgramExerciseLoaded(this.exercises, {this.isSubmitting = false});

  ProgramExerciseLoaded copyWith({
    List<ProgramExercise>? exercises,
    bool? isSubmitting,
  }) {
    return ProgramExerciseLoaded(
      exercises ?? this.exercises,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ProgramExerciseError extends ProgramExerciseState {
  final String message;

  const ProgramExerciseError(this.message);
}
