import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/workout_programs/data/models/workout_program_model.dart';

class WorkoutProgramApiDatasource {
  final ApiClient client;

  WorkoutProgramApiDatasource({required this.client});

  Future<List<WorkoutProgramModel>?> getPrograms() async {
    try {
      final data = await client.get('/workout-programs') as List<dynamic>;
      return data
          .map(
            (json) =>
                WorkoutProgramModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        return null;
      }
      rethrow;
    }
  }

  Future<WorkoutProgramModel?> createProgram(
    WorkoutProgramModel program,
  ) async {
    try {
      final data =
          await client.post('/workout-programs', program.toRequestJson())
              as Map<String, dynamic>;
      return WorkoutProgramModel.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        //Validation failed
        return null;
      }
      rethrow;
    }
  }

  Future<bool> updateProgram(WorkoutProgramModel program) async {
    try {
      await client.put(
        '/workout-programs/${program.id}',
        program.toRequestJson(),
      );
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        //Validation failed
        return false;
      }
      rethrow;
    }
  }

  Future<bool> deleteProgram(String id) async {
    try {
      await client.delete('/workout-programs/$id');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        //Validation failed
        return false;
      }
      rethrow;
    }
  }

  Future<bool> duplicateProgram(String id, String? title) async {
    try {
      await client.post(
        '/workout-programs/$id/duplicate',
        title != null ? {'title': title} : {},
      );
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        //Validation failed
        return false;
      }
      rethrow;
    }
  }
}
