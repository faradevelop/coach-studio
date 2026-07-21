import 'package:coach_studio/features/exercises/data/datasources/exercise_firestore_datasource.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseFirestoreDatasource datasource;

  ExerciseRepositoryImpl({required this.datasource});

  @override
  Stream<List<Exercise>> watchExercises() {
    return datasource.watchExercises().map(
      (models) => models.map((model) => Exercise.fromModel(model)).toList(),
    );
  }

  @override
  Future<void> addExercise(Exercise exercise) {
    return datasource.addExercise(exercise.toModel());
  }

  @override
  Future<void> updateExercise(Exercise exercise) {
    return datasource.updateExercise(exercise.toModel());
  }

  @override
  Future<void> deleteExercise(String id) {
    return datasource.deleteExercise(id);
  }
}
