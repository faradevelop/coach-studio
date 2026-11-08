import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/exercises/data/models/muscle_model.dart';

class ExerciseApiDatasource {
  final ApiClient client;
  final AppLogger _logger;

  ExerciseApiDatasource({required this.client, required this._logger});

  /// Server-side search/filter on `/exercises`. Only parameters with a value
  /// are sent.
  Future<List<ExerciseModel>> searchExercises({
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

    final data = await client.get('/exercises$queryString') as List<dynamic>;
    final exercises = data
        .map((json) => ExerciseModel.fromJson(json as Map<String, dynamic>))
        .toList();
    _logger.debug(
      'ExerciseDataSource: search returned ${exercises.length} exercises',
    );
    return exercises;
  }

  Future<ExerciseModel?> getExerciseById(String id) async {
    try {
      final data = await client.get('/exercises/$id') as Map<String, dynamic>;
      return ExerciseModel.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<ExerciseModel> createExercise(ExerciseModel exercise) async {
    final data =
        await client.post('/exercises', exercise.toRequestJson())
            as Map<String, dynamic>;
    return ExerciseModel.fromJson(data);
  }

  Future<void> updateExercise(ExerciseModel exercise) async {
    await client.put('/exercises/${exercise.id}', exercise.toRequestJson());
  }

  Future<void> deleteExercise(String id) async {
    await client.delete('/exercises/$id');
  }

  Future<List<MuscleModel>> getMuscles() async {
    final data = await client.get('/muscles') as List<dynamic>;
    final muscles = data
        .map((json) => MuscleModel.fromJson(json as Map<String, dynamic>))
        .toList();
    _logger.debug('ExerciseDataSource: loaded ${muscles.length} muscles');
    return muscles;
  }
}
