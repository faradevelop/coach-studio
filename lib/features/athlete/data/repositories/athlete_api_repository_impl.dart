import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/athlete/data/datasources/athlete_api_datasource.dart';
import 'package:coach_studio/features/athlete/data/models/athlete_model.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_filter.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_program_assignment.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_summary.dart';
import 'package:coach_studio/features/athlete/domain/repositories/athlete_repository.dart';

class AthleteApiRepositoryImpl implements AthleteRepository {
  final AthleteApiDatasource datasource;
  final AppLogger _logger;

  AthleteApiRepositoryImpl({required this.datasource, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger();

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to AthleteApiRepositoryImpl');
  }

  @override
  Future<List<Athlete>> getAthletes(AthleteFilter filter) => _guard(
    'load athletes',
    () async => (await datasource.getAthletes(
      status: filter.status.name,
      sort: filter.order.sort,
      direction: filter.order.direction,
      search: filter.search,
      hasProgram: filter.hasProgram,
    )).map((m) => m.toEntity()).toList(),
  );

  @override
  Future<AthleteSummary> getSummary() =>
      _guard('load summary', () async => (await datasource.getSummary()).toEntity());

  @override
  Future<Athlete> getAthlete(String id) =>
      _guard('load athlete', () async => (await datasource.getAthlete(id)).toEntity());

  @override
  Future<Athlete> createAthlete(Athlete athlete) => _guard(
    'create athlete',
    () async => (await datasource.createAthlete(
      AthleteModel.fromEntity(athlete),
    )).toEntity(),
  );

  @override
  Future<Athlete> updateAthlete(Athlete athlete) => _guard(
    'update athlete',
    () async => (await datasource.updateAthlete(
      AthleteModel.fromEntity(athlete),
    )).toEntity(),
  );

  @override
  Future<Athlete> archiveAthlete(String id) => _guard(
    'archive athlete',
    () async => (await datasource.archiveAthlete(id)).toEntity(),
  );

  @override
  Future<Athlete> restoreAthlete(String id) => _guard(
    'restore athlete',
    () async => (await datasource.restoreAthlete(id)).toEntity(),
  );

  @override
  Future<List<AthleteProgramAssignment>> getProgramHistory(String athleteId) =>
      _guard(
        'load program history',
        () async => (await datasource.getProgramHistory(
          athleteId,
        )).map((m) => m.toEntity()).toList(),
      );

  @override
  Future<AthleteProgramAssignment> assignProgram(
    String athleteId,
    String sourceProgramId, {
    String? title,
  }) => _guard(
    'assign program',
    () async => (await datasource.assignProgram(
      athleteId,
      sourceProgramId,
      title,
    )).toEntity(),
  );

  Future<T> _guard<T>(String action, Future<T> Function() run) async {
    try {
      return await run();
    } on ApiException catch (e) {
      _logger.error('AthleteRepository: failed to $action', error: e.message);
      throw ApiException.mapApiException(_withFirstValidationMessage(e));
    } catch (e) {
      _logger.error('AthleteRepository: unexpected error ($action)', error: e);
      rethrow;
    }
  }

  ApiException _withFirstValidationMessage(ApiException e) {
    final errors = e.errors;
    if (e.statusCode == 422 && errors != null && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        return ApiException(
          message: first.first.toString(),
          statusCode: e.statusCode,
          errors: errors,
        );
      }
    }
    return e;
  }
}
