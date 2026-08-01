import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_model.dart';

class ProgramExerciseFirestoreDatasource {
  final FirebaseFirestore firestore;

  ProgramExerciseFirestoreDatasource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('program_exercises');

  Stream<List<ProgramExerciseModel>> watchProgramExercises(String workoutId) {
    return _collection
        .where('workoutId', isEqualTo: workoutId)
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

  Future<int> getNextProgramExerciseOrder({
    required String workoutId,
    required int day,
  }) async {
    final snapshot = await firestore
        .collection('program_exercises')
        .where('workoutId', isEqualTo: workoutId)
        .where('day', isEqualTo: day)
        .orderBy('order', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return 1;
    }

    final lastOrder = snapshot.docs.first.data()['order'] as int;

    return lastOrder + 1;
  }

  Future<ProgramExerciseModel?> getProgramExerciseById(String id) async {
    final doc = await firestore.collection('program_exercises').doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return ProgramExerciseModel.fromFirestore(doc);
  }
}
