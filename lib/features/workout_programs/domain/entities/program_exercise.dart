import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_item.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';

class ProgramExercise {
  final String id;
  final String programId;
  final int day;
  final int order;
  final String sets;
  final String rest;
  final TrainingSystem trainingSystem;
  final List<ProgramExerciseItem> items;

  const ProgramExercise({
    required this.id,
    required this.programId,
    required this.day,
    required this.order,
    required this.sets,
    required this.rest,
    required this.trainingSystem,
    required this.items,
  });

  ProgramExercise copyWith({
    String? id,
    String? programId,
    int? day,
    int? order,
    String? sets,
    String? rest,
    TrainingSystem? trainingSystem,
    List<ProgramExerciseItem>? items,
  }) {
    return ProgramExercise(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      day: day ?? this.day,
      order: order ?? this.order,
      sets: sets ?? this.sets,
      rest: rest ?? this.rest,
      trainingSystem: trainingSystem ?? this.trainingSystem,
      items: items ?? this.items,
    );
  }
}
