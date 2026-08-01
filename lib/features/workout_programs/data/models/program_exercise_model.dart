import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_item_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';

class ProgramExerciseModel {
  final String id;
  final String workoutId;
  final int day;
  final int order;
  final String sets;
  final String rest;
  final TrainingSystem trainingSystem;
  final List<ProgramExerciseItemModel> items;

  const ProgramExerciseModel({
    required this.id,
    required this.workoutId,
    required this.day,
    required this.order,
    required this.sets,
    required this.rest,
    required this.trainingSystem,
    required this.items,
  });

  factory ProgramExerciseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return ProgramExerciseModel(
      id: doc.id,
      workoutId: data['workoutId'],
      day: data['day'],
      order: data['order'],
      sets: data['sets'],
      rest: data['rest'],
      trainingSystem: TrainingSystem.values.byName(data['trainingSystem']),
      // items: (data['items'] as List<dynamic>)
      //     .map((e) => ProgramExerciseItemModel.fromFirestore(e))
      //     .toList(),
      items: (data['items'] as List<dynamic>? ?? [])
          .map(
            (e) => ProgramExerciseItemModel.fromMap(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'workoutId': workoutId,
      'day': day,
      'order': order,
      'sets': sets,
      'rest': rest,
      'trainingSystem': trainingSystem.name,
      // 'items': items.map((e) => e.toFirestore()).toList(),
      'items': items.map((e) => {'id': e.id, ...e.toFirestore()}).toList(),
    };
  }

  ProgramExerciseModel copyWith({
    String? id,
    String? workoutId,
    int? day,
    int? order,
    String? sets,
    String? rest,
    TrainingSystem? trainingSystem,
    List<ProgramExerciseItemModel>? items,
  }) {
    return ProgramExerciseModel(
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

  factory ProgramExerciseModel.fromEntity(ProgramExercise entity) {
    return ProgramExerciseModel(
      id: entity.id,
      workoutId: entity.workoutId,
      day: entity.day,
      order: entity.order,
      sets: entity.sets,
      rest: entity.rest,
      trainingSystem: entity.trainingSystem,
      items: entity.items
          .map((item) => ProgramExerciseItemModel.fromEntity(item))
          .toList(),
    );
  }

  ProgramExercise toEntity() {
    return ProgramExercise(
      id: id,
      workoutId: workoutId,
      day: day,
      order: order,
      sets: sets,
      rest: rest,
      trainingSystem: trainingSystem,
      items: items.map((item) => item.toEntity()).toList(),
    );
  }
}
