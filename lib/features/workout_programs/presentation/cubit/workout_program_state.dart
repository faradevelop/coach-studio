import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';

sealed class WorkoutProgramState {}

class WorkoutProgramInitial extends WorkoutProgramState {}

class WorkoutProgramLoading extends WorkoutProgramState {}

class WorkoutProgramLoaded extends WorkoutProgramState {
  /// The FULL, unfiltered list. Dashboard stats, the detail page and the
  /// assign-program dialog depend on this, so it must never be filtered.
  final List<WorkoutProgram> programs;

  /// Server-side filtered result; null when no filter is applied.
  final List<WorkoutProgram>? filtered;

  final bool isSubmitting;

  WorkoutProgramLoaded(
    this.programs, {
    this.filtered,
    this.isSubmitting = false,
  });

  /// What the programs list page renders.
  List<WorkoutProgram> get visiblePrograms => filtered ?? programs;

  WorkoutProgramLoaded copyWith({
    List<WorkoutProgram>? programs,
    List<WorkoutProgram>? filtered,
    bool? isSubmitting,
  }) {
    return WorkoutProgramLoaded(
      programs ?? this.programs,
      filtered: filtered ?? this.filtered,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class WorkoutProgramError extends WorkoutProgramState {
  final String message;

  WorkoutProgramError(this.message);
}
