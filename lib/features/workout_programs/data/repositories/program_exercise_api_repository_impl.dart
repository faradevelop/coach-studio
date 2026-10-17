import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/workout_programs/data/datasources/program_exercise_api_datasource.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/program_exercise_repository.dart';

class ProgramExerciseApiRepositoryImpl implements ProgramExerciseRepository {
  final ProgramExerciseApiDatasource datasource;
  final AppLogger _logger;

  ProgramExerciseApiRepositoryImpl({
    required this.datasource,
    AppLogger? logger,
  }) : _logger = logger ?? _createDefaultLogger();

  static AppLogger _createDefaultLogger() {
    throw StateError(
      'AppLogger must be provided to ProgramExerciseApiRepositoryImpl',
    );
  }

  @override
  Stream<List<ProgramExerciseDetails>> watchProgramExercises(
    String workoutId,
  ) async* {
    _logger.debug(
      'ProgramExerciseRepository: loading exercises for program $workoutId',
    );
    try {
      final details = await datasource.getProgramExerciseDetails(workoutId);
      if (details != null) {
        _logger.info(
          'ProgramExerciseRepository: ${details.length} program exercises loaded',
        );
        yield details;
      }
    } on ApiException catch (e) {
      _logger.error(
        'ProgramExerciseRepository: failed to load program exercises',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'ProgramExerciseRepository: unexpected error loading program exercises',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> addProgramExercise(ProgramExercise exercise) async {
    _logger.info('ProgramExerciseRepository: adding program exercise');
    try {
      final result = await datasource.createProgramExercise(
        ProgramExerciseModel.fromEntity(exercise),
      );
      final success = result != null;
      if (success) {
        _logger.info(
          'ProgramExerciseRepository: program exercise added successfully',
        );
      } else {
        _logger.warning(
          'ProgramExerciseRepository: failed to add program exercise',
        );
      }
      return success;
    } on ApiException catch (e) {
      _logger.error(
        'ProgramExerciseRepository: error adding program exercise',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'ProgramExerciseRepository: unexpected error adding program exercise',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> updateProgramExercise(ProgramExercise exercise) async {
    _logger.info(
      'ProgramExerciseRepository: updating program exercise ${exercise.id}',
    );
    try {
      final result = await datasource.updateProgramExercise(
        ProgramExerciseModel.fromEntity(exercise),
      );
      final success = result != null;
      if (success) {
        _logger.info(
          'ProgramExerciseRepository: program exercise updated successfully',
        );
      } else {
        _logger.warning(
          'ProgramExerciseRepository: failed to update program exercise',
        );
      }
      return success;
    } on ApiException catch (e) {
      _logger.error(
        'ProgramExerciseRepository: error updating program exercise',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'ProgramExerciseRepository: unexpected error updating program exercise',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> deleteProgramExercise(String id) async {
    _logger.info('ProgramExerciseRepository: deleting program exercise $id');
    try {
      final success = await datasource.deleteProgramExercise(id);
      if (success) {
        _logger.info(
          'ProgramExerciseRepository: program exercise deleted successfully',
        );
      } else {
        _logger.warning(
          'ProgramExerciseRepository: failed to delete program exercise',
        );
      }
      return success;
    } on ApiException catch (e) {
      _logger.error(
        'ProgramExerciseRepository: error deleting program exercise',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'ProgramExerciseRepository: unexpected error deleting program exercise',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<bool> reorderProgramExercise(
    String exerciseId,
    int targetOrder,
  ) async {
    _logger.debug(
      'ProgramExerciseRepository: reordering program exercise $exerciseId to order $targetOrder',
    );
    try {
      final success = await datasource.reorderProgramExercise(
        exerciseId,
        targetOrder,
      );
      if (success) {
        _logger.debug('ProgramExerciseRepository: program exercise reordered');
      } else {
        _logger.warning(
          'ProgramExerciseRepository: failed to reorder program exercise',
        );
      }
      return success;
    } on ApiException catch (e) {
      _logger.error(
        'ProgramExerciseRepository: error reordering program exercise',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'ProgramExerciseRepository: unexpected error reordering program exercise',
        error: e,
      );
      rethrow;
    }
  }
}
