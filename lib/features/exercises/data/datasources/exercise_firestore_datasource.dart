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
}
