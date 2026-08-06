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

  factory ProgramExerciseModel.fromJson(Map<String, dynamic> json) {
    return ProgramExerciseModel(
      id: json['id'] as String,
      workoutId: json['workoutId'] as String,
      day: json['day'] as int,
      order: json['order'] as int,
      sets: json['sets'] as String,
      rest: json['rest'] as String,
      trainingSystem: TrainingSystem.values.byName(
        json['trainingSystem'] as String,
      ),
      items: (json['items'] as List<dynamic>? ?? [])
          .map(
            (e) => ProgramExerciseItemModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  //order is likewise excluded from the request body
  // order is fully computed server-side by ProgramExerciseService now
  Map<String, dynamic> toRequestJson() {
    return {
      'workoutId': workoutId,
      'day': day,
      'sets': sets,
      'rest': rest,
      'trainingSystem': trainingSystem.name,
      'items': items.map((item) => item.toRequestJson()).toList(),
    };
  }
}
