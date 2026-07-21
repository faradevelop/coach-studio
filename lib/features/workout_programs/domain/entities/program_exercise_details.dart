import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';

class ProgramExerciseDetails {
  final ProgramExercise programExercise;
  final Exercise exercise;

  const ProgramExerciseDetails({
    required this.programExercise,
    required this.exercise,
  });
}
