import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';

class WorkoutProgramDetails {
  final WorkoutProgram program;
  final List<ProgramExerciseDetails> exercises;

  const WorkoutProgramDetails({required this.program, required this.exercises});
}
