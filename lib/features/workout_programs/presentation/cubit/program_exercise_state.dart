import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';

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
  final List<ProgramExerciseDetails> exercises;
  final bool isSubmitting;

  const ProgramExerciseLoaded({
    required this.exercises,
    this.isSubmitting = false,
  });

  ProgramExerciseLoaded copyWith({
    List<ProgramExerciseDetails>? exercises,
    bool? isSubmitting,
  }) {
    return ProgramExerciseLoaded(
      exercises: exercises ?? this.exercises,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ProgramExerciseError extends ProgramExerciseState {
  final String message;

  const ProgramExerciseError(this.message);
}
