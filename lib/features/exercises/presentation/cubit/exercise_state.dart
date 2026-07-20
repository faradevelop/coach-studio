import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';

sealed class ExerciseState {}

class ExerciseInitial extends ExerciseState {}

class ExerciseLoading extends ExerciseState {}

class ExerciseLoaded extends ExerciseState {
  final List<ExerciseModel> exercises;
  final bool isSubmitting;

  ExerciseLoaded({required this.exercises, this.isSubmitting = false});

  ExerciseLoaded copyWith({
    List<ExerciseModel>? exercises,
    bool? isSubmitting,
  }) {
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
