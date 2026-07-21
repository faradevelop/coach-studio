import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_model.dart';

class ProgramExerciseFirestoreDatasource {
  final FirebaseFirestore firestore;

  ProgramExerciseFirestoreDatasource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('program_exercises');

  Stream<List<ProgramExerciseModel>> watchProgramExercises(String programId) {
    return _collection
        .where('programId', isEqualTo: programId)
        .orderBy('day')
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(ProgramExerciseModel.fromFirestore).toList(),
        );
  }

  Future<void> addProgramExercise(ProgramExerciseModel exercise) async {
    final doc = _collection.doc();

    await doc.set(exercise.copyWith(id: doc.id).toFirestore());
  }

  Future<void> updateProgramExercise(ProgramExerciseModel exercise) async {
    await _collection.doc(exercise.id).update(exercise.toFirestore());
  }

  Future<void> deleteProgramExercise(String id) async {
    await _collection.doc(id).delete();
  }
}
