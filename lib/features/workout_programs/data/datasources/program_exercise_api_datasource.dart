import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_item_model.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';

/// Errors (including 422/404) propagate as `ApiException`; the repository
/// maps them to user-presentable exceptions.
class ProgramExerciseApiDatasource {
  final ApiClient client;
  final AppLogger _logger;

  ProgramExerciseApiDatasource({required this.client, required this._logger});

  /// GET /workout-programs/{id}/program-exercises — already returns the
  /// exercise-joined shape (ProgramExerciseDetailResource).
  Future<List<ProgramExerciseDetails>> getProgramExerciseDetails(
    String workoutProgramId,
  ) async {
    final data =
        await client.get(
              '/workout-programs/$workoutProgramId/program-exercises',
            )
            as List<dynamic>;

    final details = data
        .map((json) => _detailsFromJson(json as Map<String, dynamic>))
        .toList();
    _logger.debug(
      'ProgramExerciseDataSource: loaded ${details.length} program exercises',
    );
    return details;
  }

  Future<ProgramExerciseModel> createProgramExercise(
    ProgramExerciseModel exercise,
  ) async {
    final data =
        await client.post('/program-exercises', exercise.toRequestJson())
            as Map<String, dynamic>;
    return ProgramExerciseModel.fromJson(data);
  }

  Future<ProgramExerciseModel> updateProgramExercise(
    ProgramExerciseModel exercise,
  ) async {
    final data =
        await client.put(
              '/program-exercises/${exercise.id}',
              exercise.toRequestJson(),
            )
            as Map<String, dynamic>;
    return ProgramExerciseModel.fromJson(data);
  }

  Future<void> deleteProgramExercise(String id) async {
    await client.delete('/program-exercises/$id');
  }

  Future<void> reorderProgramExercise(
    String exerciseId,
    int targetOrder,
  ) async {
    await client.patch('/program-exercises/$exerciseId/reorder', {
      'order': targetOrder,
    });
  }

  ProgramExerciseDetails _detailsFromJson(Map<String, dynamic> json) {
    final programExercise = ProgramExerciseModel.fromJson(
      json['programExercise'] as Map<String, dynamic>,
    ).toEntity();

    final items = (json['items'] as List<dynamic>).map((raw) {
      final map = raw as Map<String, dynamic>;
      final item = ProgramExerciseItemModel.fromJson(
        map['item'] as Map<String, dynamic>,
      ).toEntity();
      final exercise = ExerciseModel.fromJson(
        map['exercise'] as Map<String, dynamic>,
      ).toEntity();

      return ProgramExerciseItemDetails(item: item, exercise: exercise);
    }).toList();

    return ProgramExerciseDetails(
      programExercise: programExercise,
      items: items,
    );
  }
}
