import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';

class ProgramExerciseModel extends ProgramExercise {
  const ProgramExerciseModel({
    required super.id,
    required super.programId,
    required super.exerciseId,
    required super.day,
    required super.order,
    required super.sets,
    required super.reps,
    required super.tempo,
    required super.rest,
    required super.trainingSystem,
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
}
