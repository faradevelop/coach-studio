import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_item.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';

class ProgramExercise {
  final String id;
  final String workoutId;
  final int day;
  final int order;
  final String sets;
  final String rest;
  final TrainingSystem trainingSystem;
  final List<ProgramExerciseItem> items;

  const ProgramExercise({
    required this.id,
    required this.workoutId,
    required this.day,
    required this.order,
    required this.sets,
    required this.rest,
    required this.trainingSystem,
    required this.items,
  });

  ProgramExercise copyWith({
    String? id,
    String? workoutId,
    int? day,
    int? order,
    String? sets,
    String? rest,
    TrainingSystem? trainingSystem,
    List<ProgramExerciseItem>? items,
  }) {
    return ProgramExercise(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      day: day ?? this.day,
      order: order ?? this.order,
      sets: sets ?? this.sets,
      rest: rest ?? this.rest,
      trainingSystem: trainingSystem ?? this.trainingSystem,
      items: items ?? this.items,
    );
  }
}
