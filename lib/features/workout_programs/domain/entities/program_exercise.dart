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

  ProgramExercise copyWith({
    String? id,
    String? programId,
    String? exerciseId,
    int? day,
    int? order,
    String? sets,
    String? reps,
    String? tempo,
    String? rest,
    TrainingSystem? trainingSystem,
  }) {
    return ProgramExercise(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      exerciseId: exerciseId ?? this.exerciseId,
      day: day ?? this.day,
      order: order ?? this.order,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      tempo: tempo ?? this.tempo,
      rest: rest ?? this.rest,
      trainingSystem: trainingSystem ?? this.trainingSystem,
    );
  }
}
