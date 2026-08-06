import 'package:coach_studio/features/exercises/data/datasources/exercise_api_datasource.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';

class ExerciseApiRepositoryImpl implements ExerciseRepository {
  final ExerciseApiDatasource datasource;

  ExerciseApiRepositoryImpl({required this.datasource});

  @override
  Stream<List<Exercise>> watchExercises() async* {
    // Single-emission stream: fulfills the existing Stream<...> contract
    // without simulating real-time push updates. See Section 6 note.
    final models = await datasource.getExercises();
    yield models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addExercise(Exercise exercise) {
    return datasource.createExercise(ExerciseModel.fromEntity(exercise));
  }

  @override
  Future<void> updateExercise(Exercise exercise) {
    return datasource.updateExercise(ExerciseModel.fromEntity(exercise));
  }

  @override
  Future<void> deleteExercise(String id) {
    return datasource.deleteExercise(id);
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    final model = await datasource.getExerciseById(id);
    return model?.toEntity();
  }
}
