import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/exercises/data/models/muscle_model.dart';

class ExerciseApiDatasource {
  final ApiClient client;
  final AppLogger _logger;

  ExerciseApiDatasource({required this.client, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger();

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to ExerciseApiDatasource');
  }

  Future<List<ExerciseModel>?> getExercises() async {
    _logger.debug('ExerciseDataSource: fetching all exercises');
    try {
      final data = await client.get('/exercises') as List<dynamic>;
      final exercises = data
          .map((json) => ExerciseModel.fromJson(json as Map<String, dynamic>))
          .toList();
      _logger.info('ExerciseDataSource: loaded ${exercises.length} exercises');
      return exercises;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'ExerciseDataSource: validation error fetching exercises',
        );
        return null;
      }
      _logger.error('ExerciseDataSource: failed to fetch exercises', error: e);
      rethrow;
    }
  }

  /// Server-side search/filter — mirrors [getExercises] but forwards
  /// `search`, `type`, `difficulty`, `equipment` and a comma-separated
  /// `muscles` query parameter to the existing `/exercises` endpoint.
  /// Only parameters with a value are included.
  Future<List<ExerciseModel>?> searchExercises({
    String? search,
    String? type,
    String? difficulty,
    String? equipment,
    List<String>? muscleSlugs,
  }) async {
    final query = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (type != null && type.isNotEmpty) query['type'] = type;
    if (difficulty != null && difficulty.isNotEmpty) {
      query['difficulty'] = difficulty;
    }
    if (equipment != null && equipment.isNotEmpty) {
      query['equipment'] = equipment;
    }
    if (muscleSlugs != null && muscleSlugs.isNotEmpty) {
      query['muscles'] = muscleSlugs.join(',');
    }

    final queryString = query.isEmpty
        ? ''
        : '?${query.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

    _logger.debug('ExerciseDataSource: searching exercises ($queryString)');
    try {
      final data = await client.get('/exercises$queryString') as List<dynamic>;
      final exercises = data
          .map((json) => ExerciseModel.fromJson(json as Map<String, dynamic>))
          .toList();
      _logger.info(
        'ExerciseDataSource: search returned ${exercises.length} exercises',
      );
      return exercises;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'ExerciseDataSource: validation error searching exercises',
        );
        return null;
      }
      _logger.error('ExerciseDataSource: failed to search exercises', error: e);
      rethrow;
    }
  }

  Future<ExerciseModel?> getExerciseById(String id) async {
    _logger.debug('ExerciseDataSource: fetching exercise $id');
    try {
      final data = await client.get('/exercises/$id') as Map<String, dynamic>;
      _logger.debug('ExerciseDataSource: exercise $id retrieved');
      return ExerciseModel.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        _logger.debug('ExerciseDataSource: exercise $id not found');
        return null;
      }
      _logger.error(
        'ExerciseDataSource: failed to fetch exercise $id',
        error: e,
      );
      rethrow;
    }
  }

  Future<ExerciseModel?> createExercise(ExerciseModel exercise) async {
    _logger.debug('ExerciseDataSource: creating exercise');
    try {
      final data =
          await client.post('/exercises', exercise.toRequestJson())
              as Map<String, dynamic>;

      final created = ExerciseModel.fromJson(data);
      _logger.info('ExerciseDataSource: exercise created successfully');
      return created;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'ExerciseDataSource: validation error creating exercise',
        );
        return null;
      }
      _logger.error('ExerciseDataSource: failed to create exercise', error: e);
      rethrow;
    }
  }

  Future<bool> updateExercise(ExerciseModel exercise) async {
    _logger.debug('ExerciseDataSource: updating exercise ${exercise.id}');
    try {
      await client.put('/exercises/${exercise.id}', exercise.toRequestJson());
      _logger.info('ExerciseDataSource: exercise updated successfully');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'ExerciseDataSource: validation error updating exercise',
        );
        return false;
      }
      _logger.error(
        'ExerciseDataSource: failed to update exercise ${exercise.id}',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> deleteExercise(String id) async {
    _logger.debug('ExerciseDataSource: deleting exercise $id');
    try {
      await client.delete('/exercises/$id');
      _logger.info('ExerciseDataSource: exercise deleted successfully');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        _logger.debug('ExerciseDataSource: exercise $id not found');
        return false;
      }
      _logger.error(
        'ExerciseDataSource: failed to delete exercise $id',
        error: e,
      );
      rethrow;
    }
  }

  Future<List<MuscleModel>> getMuscles() async {
    _logger.debug('ExerciseDataSource: fetching muscles');
    final data = await client.get('/muscles') as List<dynamic>;
    print(data);
    final muscles = data
        .map((json) => MuscleModel.fromJson(json as Map<String, dynamic>))
        .toList();
    _logger.debug('ExerciseMetaDataSource: loaded ${muscles.length} muscles');
    return muscles;
  }
}
