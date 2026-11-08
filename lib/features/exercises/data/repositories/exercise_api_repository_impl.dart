import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/exercises/data/datasources/exercise_api_datasource.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';

class ExerciseApiRepositoryImpl implements ExerciseRepository {
  final ExerciseApiDatasource datasource;
  final AppLogger _logger;

  ExerciseApiRepositoryImpl({required this.datasource, required this._logger});

  @override
  Future<List<Exercise>> searchExercises({
    String? search,
    String? type,
    String? difficulty,
    String? equipment,
    List<String>? muscleSlugs,
  }) => _guard('search exercises', () async {
    final models = await datasource.searchExercises(
      search: search,
      type: type,
      difficulty: difficulty,
      equipment: equipment,
      muscleSlugs: muscleSlugs,
    );
    return models.map((m) => m.toEntity()).toList();
  });

  @override
  Future<void> addExercise(Exercise exercise) =>
      _guard<void>('add exercise', () async {
        await datasource.createExercise(ExerciseModel.fromEntity(exercise));
      });

  @override
  Future<void> updateExercise(Exercise exercise) =>
      _guard<void>('update exercise ${exercise.id}', () {
        return datasource.updateExercise(ExerciseModel.fromEntity(exercise));
      });

  @override
  Future<void> deleteExercise(String id) =>
      _guard<void>('delete exercise $id', () => datasource.deleteExercise(id));

  @override
  Future<Exercise?> getExerciseById(String id) =>
      _guard('fetch exercise $id', () async {
        final model = await datasource.getExerciseById(id);
        return model?.toEntity();
      });

  @override
  Future<List<Muscle>> getMuscles() => _guard('load muscles', () async {
    final models = await datasource.getMuscles();
    return models.map((m) => m.toEntity()).toList();
  });

  Future<T> _guard<T>(String action, Future<T> Function() run) async {
    try {
      return await run();
    } on ApiException catch (e) {
      _logger.error('ExerciseRepository: failed to $action', error: e.message);
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error('ExerciseRepository: unexpected error ($action)', error: e);
      rethrow;
    }
  }
}
