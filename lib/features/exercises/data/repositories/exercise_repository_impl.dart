import 'package:coach_studio/features/exercises/data/datasources/exercise_firestore_datasource.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseFirestoreDatasource datasource;

  ExerciseRepositoryImpl({required this.datasource});

  @override
  Stream<List<ExerciseModel>> watchExercises() {
    return datasource.watchExercises();
  }

  @override
  Future<void> addExercise(ExerciseModel exercise) {
    return datasource.addExercise(exercise);
  }

  @override
  Future<void> updateExercise(ExerciseModel exercise) {
    return datasource.updateExercise(exercise);
  }

  @override
  Future<void> deleteExercise(String id) {
    return datasource.deleteExercise(id);
  }
}
