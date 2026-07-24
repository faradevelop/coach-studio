import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_draft.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';

class ProgramExerciseConfigurationArgs {
  final WorkoutProgram program;
  final ProgramExerciseDraft draft;
  final List<Exercise> exercises;

  const ProgramExerciseConfigurationArgs({
    required this.program,
    required this.draft,
    required this.exercises,
  });
}
