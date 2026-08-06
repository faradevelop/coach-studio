import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';

class ExerciseApiDatasource {
  final ApiClient client;

  ExerciseApiDatasource({required this.client});

  Future<List<ExerciseModel>> getExercises() async {
    final data = await client.get('/exercises') as List<dynamic>;
    return data
        .map((json) => ExerciseModel.fromJson(json as Map<String, dynamic>))
        .toList();
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
}
