import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/workout_programs/data/datasources/workout_program_api_datasource.dart';
import 'package:coach_studio/features/workout_programs/data/models/workout_program_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_filter.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';

class WorkoutProgramApiRepositoryImpl implements WorkoutProgramRepository {
  final WorkoutProgramApiDatasource datasource;
  final AppLogger _logger;

  WorkoutProgramApiRepositoryImpl({
    required this.datasource,
    required this._logger,
  });

  @override
  Future<List<WorkoutProgram>> getPrograms({
    WorkoutProgramFilter filter = const WorkoutProgramFilter(),
  }) => _guard('load programs', () async {
    final models = await datasource.getPrograms(
      search: filter.search,
      status: filter.status == ProgramStatusFilter.all
          ? null
          : filter.status.name,
      goal: filter.goal?.name,
      level: filter.level?.name,
    );
    return models.map((m) => m.toEntity()).toList();
  });

  @override
  Future<WorkoutProgram> addProgram(WorkoutProgram program) =>
      _guard('add program', () async {
        final created = await datasource.createProgram(
          WorkoutProgramModel.fromEntity(program),
        );
        return created.toEntity();
      });

  @override
  Future<void> updateProgram(WorkoutProgram program) => _guard<void>(
    'update program ${program.id}',
    () {
      return datasource.updateProgram(WorkoutProgramModel.fromEntity(program));
    },
  );

  @override
  Future<void> deleteProgram(String id) =>
      _guard<void>('delete program $id', () => datasource.deleteProgram(id));

  @override
  Future<void> duplicateProgram(String id, String title) => _guard<void>(
    'duplicate program $id',
    () => datasource.duplicateProgram(id, title),
  );

  @override
  Future<WorkoutProgram> addDay(String programId) =>
      _guard('add day to program $programId', () async {
        final updated = await datasource.addDay(programId);
        return updated.toEntity();
      });

  @override
  Future<void> deleteDay(String programId, int day) => _guard<void>(
    'delete day $day of program $programId',
    () => datasource.deleteDay(programId, day),
  );

  @override
  Future<void> reorderDay(String programId, int day, int targetOrder) =>
      _guard<void>(
        'move day $day to $targetOrder in program $programId',
        () => datasource.reorderDay(programId, day, targetOrder),
      );

  Future<T> _guard<T>(String action, Future<T> Function() run) async {
    try {
      return await run();
    } on ApiException catch (e) {
      _logger.error(
        'WorkoutProgramRepository: failed to $action',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'WorkoutProgramRepository: unexpected error ($action)',
        error: e,
      );
      rethrow;
    }
  }
}
