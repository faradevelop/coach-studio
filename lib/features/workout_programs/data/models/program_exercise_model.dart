import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';

class ProgramExerciseModel {
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

  const ProgramExerciseModel({
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

  factory ProgramExerciseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return ProgramExerciseModel(
      id: doc.id,
      programId: data['programId'],
      exerciseId: data['exerciseId'],
      day: data['day'],
      order: data['order'],
      sets: data['sets'],
      reps: data['reps'],
      tempo: data['tempo'],
      rest: data['rest'],
      trainingSystem: TrainingSystem.values.byName(data['trainingSystem']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'programId': programId,
      'exerciseId': exerciseId,
      'day': day,
      'order': order,
      'sets': sets,
      'reps': reps,
      'tempo': tempo,
      'rest': rest,
      'trainingSystem': trainingSystem.name,
    };
  }

  ProgramExerciseModel copyWith({
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
    return ProgramExerciseModel(
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

  factory ProgramExerciseModel.fromEntity(ProgramExercise entity) {
    return ProgramExerciseModel(
      id: entity.id,
      programId: entity.programId,
      exerciseId: entity.exerciseId,
      day: entity.day,
      order: entity.order,
      sets: entity.sets,
      reps: entity.reps,
      tempo: entity.tempo,
      rest: entity.rest,
      trainingSystem: entity.trainingSystem,
    );
  }

  ProgramExercise toEntity() {
    return ProgramExercise(
      id: id,
      programId: programId,
      exerciseId: exerciseId,
      day: day,
      order: order,
      sets: sets,
      reps: reps,
      tempo: tempo,
      rest: rest,
      trainingSystem: trainingSystem,
    );
  }
}
