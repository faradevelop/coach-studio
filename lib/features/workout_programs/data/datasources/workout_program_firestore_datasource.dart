import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_studio/features/workout_programs/data/models/workout_program_model.dart';

class WorkoutProgramFirestoreDatasource {
  final FirebaseFirestore firestore;

  WorkoutProgramFirestoreDatasource({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection('workout_programs');

  Stream<List<WorkoutProgramModel>> watchPrograms() {
    return _collection
        .orderBy('title')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(WorkoutProgramModel.fromFirestore).toList(),
        );
  }

  Future<void> addProgram(WorkoutProgramModel program) async {
    final doc = _collection.doc();

    await doc.set(program.copyWith(id: doc.id).toFirestore());
  }

  Future<void> updateProgram(WorkoutProgramModel program) async {
    await _collection.doc(program.id).update(program.toFirestore());
  }

  Future<void> deleteProgram(String id) async {
    await _collection.doc(id).delete();
  }
}
