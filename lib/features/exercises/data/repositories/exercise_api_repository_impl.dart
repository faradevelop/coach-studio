import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/exercises/data/datasources/exercise_api_datasource.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';

class ExerciseApiRepositoryImpl implements ExerciseRepository {
  final ExerciseApiDatasource datasource;
  final AppLogger _logger;

  ExerciseApiRepositoryImpl({required this.datasource, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger();

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to ExerciseApiRepositoryImpl');
  }

  @override
  Stream<List<Exercise>> watchExercises() async* {
    // Single-emission stream: fulfills the existing Stream<...> contract
    // without simulating real-time push updates. See Section 6 note.
    _logger.debug('ExerciseRepository: loading exercises');
    try {
      final models = await datasource.getExercises();
      if (models != null) {
        final exercises = models.map((model) => model.toEntity()).toList();
        _logger.info(
          'ExerciseRepository: ${exercises.length} exercises loaded',
        );
        yield exercises;
      }
    } on ApiException catch (e) {
      _logger.error(
        'ExerciseRepository: failed to load exercises',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'ExerciseRepository: unexpected error loading exercises',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> addExercise(Exercise exercise) async {
    _logger.info('ExerciseRepository: adding exercise');
    try {
      final result = await datasource.createExercise(
        ExerciseModel.fromEntity(exercise),
      );
      final success = result != null;
      if (success) {
        _logger.info('ExerciseRepository: exercise added successfully');
      } else {
        _logger.warning('ExerciseRepository: failed to add exercise');
      }
      return success;
    } on ApiException catch (e) {
      _logger.error(
        'ExerciseRepository: error adding exercise',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'ExerciseRepository: unexpected error adding exercise',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> updateExercise(Exercise exercise) async {
    _logger.info('ExerciseRepository: updating exercise ${exercise.id}');
    try {
      final success = await datasource.updateExercise(
        ExerciseModel.fromEntity(exercise),
      );
      if (success) {
        _logger.info('ExerciseRepository: exercise updated successfully');
      } else {
        _logger.warning('ExerciseRepository: failed to update exercise');
      }
      return success;
    } on ApiException catch (e) {
      _logger.error(
        'ExerciseRepository: error updating exercise',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'ExerciseRepository: unexpected error updating exercise',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> deleteExercise(String id) async {
    _logger.info('ExerciseRepository: deleting exercise $id');
    try {
      final success = await datasource.deleteExercise(id);
      if (success) {
        _logger.info('ExerciseRepository: exercise deleted successfully');
      } else {
        _logger.warning('ExerciseRepository: failed to delete exercise');
      }
      return success;
    } on ApiException catch (e) {
      _logger.error(
        'ExerciseRepository: error deleting exercise',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'ExerciseRepository: unexpected error deleting exercise',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    _logger.debug('ExerciseRepository: fetching exercise $id');
    try {
      final model = await datasource.getExerciseById(id);
      if (model != null) {
        _logger.debug('ExerciseRepository: exercise $id retrieved');
      } else {
        _logger.debug('ExerciseRepository: exercise $id not found');
      }
      return model?.toEntity();
    } on ApiException catch (e) {
      _logger.error(
        'ExerciseRepository: error fetching exercise $id',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'ExerciseRepository: unexpected error fetching exercise',
        error: e,
      );
      rethrow;
    }
  }
}
