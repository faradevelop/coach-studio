import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_draft.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';

class ProgramExerciseSelectionArgs {
  final WorkoutProgram program;
  final ProgramExerciseDraft draft;

  const ProgramExerciseSelectionArgs({
    required this.program,
    required this.draft,
  });
}
