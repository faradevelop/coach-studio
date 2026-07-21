import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';

class ProgramExercise {
  final String id;

  final String programId;

  final String exerciseId;

  final int day;

  final int order;

  final String sets;

  final String reps;

  final String tempo;

  final String rest;

  final TrainingSystem trainingSystem;

  const ProgramExercise({
    required this.id,
    required this.programId,
    required this.exerciseId,
    required this.day,
    required this.order,
    required this.sets,
    required this.reps,
    required this.tempo,
    required this.rest,
    required this.trainingSystem,
  });
}
