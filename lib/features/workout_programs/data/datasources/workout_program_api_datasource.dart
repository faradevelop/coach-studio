import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/features/workout_programs/data/models/workout_program_model.dart';

/// Errors (including 422) propagate as `ApiException`; the repository maps
/// them, so server validation messages ("max 7 days", "assigned program
/// cannot be deleted", ...) are no longer lost.
class WorkoutProgramApiDatasource {
  final ApiClient client;
  final AppLogger _logger;

  WorkoutProgramApiDatasource({required this.client, required this._logger});

  Future<List<WorkoutProgramModel>> getPrograms({
    String? search,
    String? status,
    String? goal,
    String? level,
  }) async {
    final query = <String, String>{};
    final term = search?.trim() ?? '';
    if (term.isNotEmpty) {
      // Backend max length for `search` is 100.
      query['search'] = term.length > 100 ? term.substring(0, 100) : term;
    }
    if (status != null && status.isNotEmpty) query['status'] = status;
    if (goal != null && goal.isNotEmpty) query['goal'] = goal;
    if (level != null && level.isNotEmpty) query['level'] = level;

    final qs = query.isEmpty
        ? ''
        : '?${query.entries.map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}').join('&')}';

    final data = await client.get('/workout-programs$qs') as List<dynamic>;
    final programs = data
        .map(
          (json) => WorkoutProgramModel.fromJson(json as Map<String, dynamic>),
        )
        .toList();
    _logger.debug(
      'WorkoutProgramDataSource: loaded ${programs.length} programs',
    );
    return programs;
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

  Future<void> duplicateProgram(String id, String? title) async {
    await client.post(
      '/workout-programs/$id/duplicate',
      title != null ? {'title': title} : {},
    );
  }

  Future<WorkoutProgramModel> addDay(String programId) async {
    final data =
        await client.post('/workout-programs/$programId/days', const {})
            as Map<String, dynamic>;
    return WorkoutProgramModel.fromJson(data);
  }

  Future<void> deleteDay(String programId, int day) async {
    await client.delete('/workout-programs/$programId/days/$day');
  }

  Future<void> reorderDay(String programId, int day, int targetDay) async {
    await client.patch('/workout-programs/$programId/days/$day/reorder', {
      'order': targetDay,
    });
  }
}
