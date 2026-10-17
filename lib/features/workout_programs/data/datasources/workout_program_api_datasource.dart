import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/workout_programs/data/models/workout_program_model.dart';

class WorkoutProgramApiDatasource {
  final ApiClient client;
  final AppLogger _logger;

  WorkoutProgramApiDatasource({required this.client, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger();

  static AppLogger _createDefaultLogger() {
    throw StateError(
      'AppLogger must be provided to WorkoutProgramApiDatasource',
    );
  }

  Future<List<WorkoutProgramModel>?> getPrograms() async {
    _logger.debug('WorkoutProgramDataSource: fetching all programs');
    try {
      final data = await client.get('/workout-programs') as List<dynamic>;
      final programs = data
          .map(
            (json) =>
                WorkoutProgramModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      _logger.info(
        'WorkoutProgramDataSource: loaded ${programs.length} programs',
      );
      return programs;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'WorkoutProgramDataSource: validation error fetching programs',
        );
        return null;
      }
      _logger.error(
        'WorkoutProgramDataSource: failed to fetch programs',
        error: e,
      );
      rethrow;
    }
  }

  Future<WorkoutProgramModel?> createProgram(
    WorkoutProgramModel program,
  ) async {
    _logger.debug('WorkoutProgramDataSource: creating program');
    try {
      final data =
          await client.post('/workout-programs', program.toRequestJson())
              as Map<String, dynamic>;
      _logger.info('WorkoutProgramDataSource: program created successfully');
      return WorkoutProgramModel.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'WorkoutProgramDataSource: validation error creating program',
        );
        return null;
      }
      _logger.error(
        'WorkoutProgramDataSource: failed to create program',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> updateProgram(WorkoutProgramModel program) async {
    _logger.debug('WorkoutProgramDataSource: updating program ${program.id}');
    try {
      await client.put(
        '/workout-programs/${program.id}',
        program.toRequestJson(),
      );
      _logger.info('WorkoutProgramDataSource: program updated successfully');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'WorkoutProgramDataSource: validation error updating program',
        );
        return false;
      }
      _logger.error(
        'WorkoutProgramDataSource: failed to update program ${program.id}',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> deleteProgram(String id) async {
    _logger.debug('WorkoutProgramDataSource: deleting program $id');
    try {
      await client.delete('/workout-programs/$id');
      _logger.info('WorkoutProgramDataSource: program deleted successfully');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'WorkoutProgramDataSource: validation error deleting program',
        );
        return false;
      }
      _logger.error(
        'WorkoutProgramDataSource: failed to delete program $id',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> duplicateProgram(String id, String? title) async {
    _logger.debug('WorkoutProgramDataSource: duplicating program $id');
    try {
      await client.post(
        '/workout-programs/$id/duplicate',
        title != null ? {'title': title} : {},
      );
      _logger.info('WorkoutProgramDataSource: program duplicated successfully');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'WorkoutProgramDataSource: validation error duplicating program',
        );
        return false;
      }
      _logger.error(
        'WorkoutProgramDataSource: failed to duplicate program $id',
        error: e,
      );
      rethrow;
    }
  }

  Future<WorkoutProgramModel?> addDay(String programId) async {
    _logger.debug('WorkoutProgramDataSource: adding day to program $programId');

    try {
      final data =
          await client.post('/workout-programs/$programId/days', const {})
              as Map<String, dynamic>;

      _logger.info('WorkoutProgramDataSource: day added successfully');
      return WorkoutProgramModel.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'WorkoutProgramDataSource: validation error adding day',
        );
        return null;
      }

      _logger.error(
        'WorkoutProgramDataSource: failed to add day to program $programId',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> deleteDay(String programId, int day) async {
    _logger.debug(
      'WorkoutProgramDataSource: deleting day $day of program $programId',
    );

    try {
      await client.delete('/workout-programs/$programId/days/$day');

      _logger.info('WorkoutProgramDataSource: day deleted successfully');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'WorkoutProgramDataSource: validation error deleting day',
        );
        return false;
      }

      _logger.error(
        'WorkoutProgramDataSource: failed to delete day $day of program $programId',
        error: e,
      );
      rethrow;
    }
  }

  Future<bool> reorderDay(String programId, int day, int targetDay) async {
    _logger.debug(
      'WorkoutProgramDataSource: moving day $day to $targetDay '
      'in program $programId',
    );

    try {
      await client.patch('/workout-programs/$programId/days/$day/reorder', {
        'order': targetDay,
      });

      _logger.info('WorkoutProgramDataSource: day reordered successfully');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 422) {
        _logger.warning(
          'WorkoutProgramDataSource: validation error reordering day',
        );
        return false;
      }

      _logger.error(
        'WorkoutProgramDataSource: failed to reorder day $day '
        'in program $programId',
        error: e,
      );
      rethrow;
    }
  }
}
