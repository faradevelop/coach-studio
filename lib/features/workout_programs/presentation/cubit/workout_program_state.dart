import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';

sealed class WorkoutProgramState {}

class WorkoutProgramInitial extends WorkoutProgramState {}

class WorkoutProgramLoading extends WorkoutProgramState {}

class WorkoutProgramLoaded extends WorkoutProgramState {
  final List<WorkoutProgram> programs;

  final bool isSubmitting;

  WorkoutProgramLoaded(this.programs, {this.isSubmitting = false});
}

class WorkoutProgramError extends WorkoutProgramState {
  final String message;

  WorkoutProgramError(this.message);
}
