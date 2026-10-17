import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_item.dart';

class ProgramExerciseDetails {
  final ProgramExercise programExercise;
  final List<ProgramExerciseItemDetails> items;

  const ProgramExerciseDetails({
    required this.programExercise,
    required this.items,
  });
}

class ProgramExerciseItemDetails {
  final ProgramExerciseItem item;
  final Exercise exercise;

  const ProgramExerciseItemDetails({
    required this.item,
    required this.exercise,
  });
}
