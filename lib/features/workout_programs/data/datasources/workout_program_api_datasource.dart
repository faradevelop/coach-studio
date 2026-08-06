import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/features/workout_programs/data/models/workout_program_model.dart';

class WorkoutProgramApiDatasource {
  final ApiClient client;

  WorkoutProgramApiDatasource({required this.client});

  Future<List<WorkoutProgramModel>> getPrograms() async {
    final data = await client.get('/workout-programs') as List<dynamic>;
    return data
        .map(
          (json) => WorkoutProgramModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  Future<WorkoutProgramModel> createProgram(WorkoutProgramModel program) async {
    final data =
        await client.post('/workout-programs', program.toRequestJson())
            as Map<String, dynamic>;
    return WorkoutProgramModel.fromJson(data);
  }

  Future<void> updateProgram(WorkoutProgramModel program) async {
    await client.put(
      '/workout-programs/${program.id}',
      program.toRequestJson(),
    );
  }

  Future<void> deleteProgram(String id) async {
    await client.delete('/workout-programs/$id');
  }
}
