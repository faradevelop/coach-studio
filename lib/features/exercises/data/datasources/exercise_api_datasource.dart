import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';

class ExerciseApiDatasource {
  final ApiClient client;

  ExerciseApiDatasource({required this.client});

  Future<List<ExerciseModel>?> getExercises() async {
    try {
      final data = await client.get('/exercises') as List<dynamic>;
      return data
          .map((json) => ExerciseModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        return null;
      }
      rethrow;
    }
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

  Future<ExerciseModel?> createExercise(ExerciseModel exercise) async {
    try {
      final data =
          await client.post('/exercises', exercise.toRequestJson())
              as Map<String, dynamic>;

      return ExerciseModel.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        //Validation failed
        return null;
      }
      rethrow;
    }
  }

  Future<bool> updateExercise(ExerciseModel exercise) async {
    try {
      await client.put('/exercises/${exercise.id}', exercise.toRequestJson());
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        return false;
      }
      rethrow;
    }
  }

  Future<bool> deleteExercise(String id) async {
    try {
      await client.delete('/exercises/$id');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return false;
      }
      rethrow;
    }
  }
}
