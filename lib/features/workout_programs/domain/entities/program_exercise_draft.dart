import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';

class ProgramExerciseDraft {
  final String programId;
  final int day;
  final TrainingSystem trainingSystem;

  const ProgramExerciseDraft({
    required this.programId,
    required this.day,
    required this.trainingSystem,
  });
}
