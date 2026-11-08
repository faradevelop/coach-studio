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
    required this._logger,
  });

  @override
  Future<List<ProgramExerciseDetails>> getProgramExercises(String workoutId) =>
      _guard(
        'load program exercises',
        () => datasource.getProgramExerciseDetails(workoutId),
      );

  @override
  Future<void> addProgramExercise(ProgramExercise exercise) =>
      _guard<void>('add program exercise', () async {
        await datasource.createProgramExercise(
          ProgramExerciseModel.fromEntity(exercise),
        );
      });

  @override
  Future<void> updateProgramExercise(ProgramExercise exercise) =>
      _guard<void>('update program exercise ${exercise.id}', () async {
        await datasource.updateProgramExercise(
          ProgramExerciseModel.fromEntity(exercise),
        );
      });

  @override
  Future<void> deleteProgramExercise(String id) => _guard<void>(
    'delete program exercise $id',
    () => datasource.deleteProgramExercise(id),
  );

  @override
  Future<void> reorderProgramExercise(String exerciseId, int targetOrder) =>
      _guard<void>(
        'reorder program exercise $exerciseId',
        () => datasource.reorderProgramExercise(exerciseId, targetOrder),
      );

  Future<T> _guard<T>(String action, Future<T> Function() run) async {
    try {
      return await run();
    } on ApiException catch (e) {
      _logger.error(
        'ProgramExerciseRepository: failed to $action',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'ProgramExerciseRepository: unexpected error ($action)',
        error: e,
      );
      rethrow;
    }
  }
}
