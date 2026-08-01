import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_item.dart';

class ProgramExerciseItemModel {
  final String id;
  final String programExerciseId;
  final String exerciseId;
  final int order;
  final String reps;
  final String tempo;
  final String? description;

  const ProgramExerciseItemModel({
    required this.id,
    required this.programExerciseId,
    required this.exerciseId,
    required this.order,
    required this.reps,
    required this.tempo,
    this.description,
  });

  // factory ProgramExerciseItemModel.fromFirestore(
  //   DocumentSnapshot<Map<String, dynamic>> doc,
  // ) {
  //   final data = doc.data()!;

  //   return ProgramExerciseItemModel(
  //     id: doc.id,
  //     programExerciseId: data['programExerciseId'],
  //     exerciseId: data['exerciseId'],
  //     order: data['order'],
  //     reps: data['reps'],
  //     tempo: data['tempo'],
  //   );
  // }

  Map<String, dynamic> toFirestore() {
    return {
      'programExerciseId': programExerciseId,
      'exerciseId': exerciseId,
      'order': order,
      'reps': reps,
      'tempo': tempo,
      'description': description,
    };
  }

  factory ProgramExerciseItemModel.fromEntity(ProgramExerciseItem entity) {
    return ProgramExerciseItemModel(
      id: entity.id,
      programExerciseId: entity.programExerciseId,
      exerciseId: entity.exerciseId,
      order: entity.order,
      reps: entity.reps,
      tempo: entity.tempo,
      description: entity.description,
    );
  }

  ProgramExerciseItem toEntity() {
    return ProgramExerciseItem(
      id: id,
      programExerciseId: programExerciseId,
      exerciseId: exerciseId,
      order: order,
      reps: reps,
      tempo: tempo,
      description: description,
    );
  }

  factory ProgramExerciseItemModel.fromMap(Map<String, dynamic> data) {
    return ProgramExerciseItemModel(
      id: data['id'] ?? '',
      programExerciseId: data['programExerciseId'] ?? '',
      exerciseId: data['exerciseId'],
      order: data['order'],
      reps: data['reps'],
      tempo: data['tempo'],
      description: data['description'],
    );
  }
}
