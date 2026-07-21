import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';

class ExerciseFirestoreDatasource {
  final FirebaseFirestore firestore;

  ExerciseFirestoreDatasource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('exercises');

  Stream<List<ExerciseModel>> watchExercises() {
    return _collection
        .where('isActive', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(ExerciseModel.fromFirestore).toList(),
        );
  }

  Future<void> addExercise(ExerciseModel exercise) async {
    await _collection.add(exercise.toFirestore());
  }

  Future<void> updateExercise(ExerciseModel exercise) async {
    await _collection.doc(exercise.id).update(exercise.toFirestore());
  }

  Future<void> deleteExercise(String id) async {
    await _collection.doc(id).update({'isActive': false});
  }

  Future<ExerciseModel?> getExerciseById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) {
      return null;
    }

    return ExerciseModel.fromFirestore(doc);
  }
}
