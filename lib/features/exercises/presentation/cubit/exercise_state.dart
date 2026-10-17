import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';

sealed class ExerciseState {}

class ExerciseInitial extends ExerciseState {}

class ExerciseLoading extends ExerciseState {}

class ExerciseLoaded extends ExerciseState {
  final List<Exercise> exercises;
  final bool isSubmitting;

  ExerciseLoaded({required this.exercises, this.isSubmitting = false});

  ExerciseLoaded copyWith({List<Exercise>? exercises, bool? isSubmitting}) {
    return ExerciseLoaded(
      exercises: exercises ?? this.exercises,

      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ExerciseError extends ExerciseState {
  final String message;

  ExerciseError(this.message);
}
