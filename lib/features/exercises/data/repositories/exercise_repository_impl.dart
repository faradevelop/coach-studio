import 'package:coach_studio/features/exercises/data/datasources/exercise_firestore_datasource.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final ExerciseFirestoreDatasource datasource;

  ExerciseRepositoryImpl({required this.datasource});

  @override
  Future<List<ExerciseModel>> getExercises() {
    return datasource.getExercises();
  }

  @override
  Future<void> addExercise(ExerciseModel exercise) {
    return datasource.addExercise(exercise);
  }
}
