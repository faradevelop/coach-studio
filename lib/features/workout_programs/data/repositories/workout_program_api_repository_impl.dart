import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/workout_programs/data/datasources/workout_program_api_datasource.dart';
import 'package:coach_studio/features/workout_programs/data/models/workout_program_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';

class WorkoutProgramApiRepositoryImpl implements WorkoutProgramRepository {
  final WorkoutProgramApiDatasource datasource;
  final AppLogger _logger;

  WorkoutProgramApiRepositoryImpl({required this.datasource, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger();

  static AppLogger _createDefaultLogger() {
    throw StateError(
      'AppLogger must be provided to WorkoutProgramApiRepositoryImpl',
    );
  }

  @override
  Stream<List<WorkoutProgram>> watchPrograms() async* {
    _logger.debug('WorkoutProgramRepository: loading programs');
    try {
      final models = await datasource.getPrograms();
      if (models != null) {
        final programs = models.map((m) => m.toEntity()).toList();
        _logger.info(
          'WorkoutProgramRepository: ${programs.length} programs loaded',
        );
        yield programs;
      }
    } on ApiException catch (e) {
      _logger.error(
        'WorkoutProgramRepository: failed to load programs',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'WorkoutProgramRepository: unexpected error loading programs',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<WorkoutProgram?> addProgram(WorkoutProgram program) async {
    _logger.info('WorkoutProgramRepository: adding program');
    try {
      final created = await datasource.createProgram(
        WorkoutProgramModel.fromEntity(program),
      );
      if (created != null) {
        _logger.info('WorkoutProgramRepository: program added successfully');
        return created.toEntity();
      }
      _logger.warning('WorkoutProgramRepository: failed to add program');
      return null;
    } on ApiException catch (e) {
      _logger.error(
        'WorkoutProgramRepository: error adding program',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'WorkoutProgramRepository: unexpected error adding program',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> updateProgram(WorkoutProgram program) async {
    _logger.info('WorkoutProgramRepository: updating program ${program.id}');
    try {
      final success = await datasource.updateProgram(
        WorkoutProgramModel.fromEntity(program),
      );
      if (success) {
        _logger.info('WorkoutProgramRepository: program updated successfully');
      } else {
        _logger.warning('WorkoutProgramRepository: failed to update program');
      }
      return success;
    } on ApiException catch (e) {
      _logger.error(
        'WorkoutProgramRepository: error updating program',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'WorkoutProgramRepository: unexpected error updating program',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> deleteProgram(String id) async {
    _logger.info('WorkoutProgramRepository: deleting program $id');
    try {
      final success = await datasource.deleteProgram(id);
      if (success) {
        _logger.info('WorkoutProgramRepository: program deleted successfully');
      } else {
        _logger.warning('WorkoutProgramRepository: failed to delete program');
      }
      return success;
    } on ApiException catch (e) {
      _logger.error(
        'WorkoutProgramRepository: error deleting program',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'WorkoutProgramRepository: unexpected error deleting program',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> duplicateProgram(String id, String title) async {
    _logger.info('WorkoutProgramRepository: duplicating program $id');
    try {
      final success = await datasource.duplicateProgram(id, title);
      if (success) {
        _logger.info(
          'WorkoutProgramRepository: program duplicated successfully',
        );
      } else {
        _logger.warning(
          'WorkoutProgramRepository: failed to duplicate program',
        );
      }
      return success;
    } on ApiException catch (e) {
      _logger.error(
        'WorkoutProgramRepository: error duplicating program',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'WorkoutProgramRepository: unexpected error duplicating program',
        error: e,
      );
      rethrow;
    }
  }
}
