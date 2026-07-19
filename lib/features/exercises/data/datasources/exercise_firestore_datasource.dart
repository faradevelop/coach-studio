import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';

class ExerciseFirestoreDatasource {
  final FirebaseFirestore firestore;

  ExerciseFirestoreDatasource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('exercises');

  Future<List<ExerciseModel>> getExercises() async {
    final snapshot = await _collection.where('isActive', isEqualTo: true).get();

    return snapshot.docs
        .map((doc) => ExerciseModel.fromFirestore(doc))
        .toList();
  }

  Future<void> addExercise(ExerciseModel exercise) async {
    await _collection.add(exercise.toFirestore());
  }
}
