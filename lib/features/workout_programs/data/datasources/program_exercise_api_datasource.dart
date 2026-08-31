import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_item_model.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';

class ProgramExerciseApiDatasource {
  final ApiClient client;
  final AppLogger _logger;

  ProgramExerciseApiDatasource({required this.client, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger();

  static AppLogger _createDefaultLogger() {
    throw StateError(
      'AppLogger must be provided to ProgramExerciseApiDatasource',
    );
  }

  /// Calls GET /workout-programs/{workoutProgramId}/program-exercises,
  /// which already returns the exercise-joined shape
  /// (ProgramExerciseDetailResource) — no separate per-item exercise
  /// lookup is needed client-side, unlike the old Firestore flow.
  Future<List<ProgramExerciseDetails>?> getProgramExerciseDetails(
    String workoutProgramId,
  ) async {
    _logger.debug(
      'ProgramExerciseDataSource: fetching exercises for program $workoutProgramId',
    );
    try {
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
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'ProgramExerciseDataSource: validation error fetching program exercises',
        );
        return null;
      }
      _logger.error(
        'ProgramExerciseDataSource: failed to fetch program exercises',
        error: e,
      );
      rethrow;
    }
  }

  Future<ProgramExerciseModel?> createProgramExercise(
    ProgramExerciseModel exercise,
  ) async {
    _logger.debug('ProgramExerciseDataSource: creating program exercise');
    try {
      final data =
          await client.post('/program-exercises', exercise.toRequestJson())
              as Map<String, dynamic>;
      _logger.info(
        'ProgramExerciseDataSource: program exercise created successfully',
      );
      return ProgramExerciseModel.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'ProgramExerciseDataSource: validation error creating program exercise',
        );
        return null;
      }
      _logger.error(
        'ProgramExerciseDataSource: failed to create program exercise',
        error: e,
      );
      rethrow;
    }
  }

  Future<ProgramExerciseModel?> updateProgramExercise(
    ProgramExerciseModel exercise,
  ) async {
    _logger.debug(
      'ProgramExerciseDataSource: updating program exercise ${exercise.id}',
    );
    try {
      final data =
          await client.put(
                '/program-exercises/${exercise.id}',
                exercise.toRequestJson(),
              )
              as Map<String, dynamic>;
      _logger.info(
        'ProgramExerciseDataSource: program exercise updated successfully',
      );
      return ProgramExerciseModel.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'ProgramExerciseDataSource: validation error updating program exercise',
        );
        return null;
      }
      _logger.error(
        'ProgramExerciseDataSource: failed to update program exercise ${exercise.id}',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> deleteProgramExercise(String id) async {
    _logger.debug('ProgramExerciseDataSource: deleting program exercise $id');
    try {
      await client.delete('/program-exercises/$id');
      _logger.info('ProgramExerciseDataSource: program exercise deleted');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        _logger.debug(
          'ProgramExerciseDataSource: program exercise $id not found',
        );
        return false;
      }
      _logger.error(
        'ProgramExerciseDataSource: failed to delete program exercise $id',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> reorderProgramExercise(
    String exerciseId,
    int targetOrder,
  ) async {
    _logger.debug(
      'ProgramExerciseDataSource: reordering program exercise $exerciseId to order $targetOrder',
    );
    try {
      await client.patch('/program-exercises/$exerciseId/reorder', {
        'order': targetOrder,
      });
      _logger.debug('ProgramExerciseDataSource: program exercise reordered');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'ProgramExerciseDataSource: validation error reordering program exercise',
        );
        return false;
      }
      _logger.error(
        'ProgramExerciseDataSource: failed to reorder program exercise $exerciseId',
        error: e,
      );
      rethrow;
    }
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
