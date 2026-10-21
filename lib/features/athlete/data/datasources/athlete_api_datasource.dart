import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/features/athlete/data/models/athlete_model.dart';
import 'package:coach_studio/features/athlete/data/models/athlete_program_assignment_model.dart';
import 'package:coach_studio/features/athlete/data/models/athlete_summary_model.dart';

class AthleteApiDatasource {
  final ApiClient client;
  final AppLogger _logger;

  AthleteApiDatasource({required this.client, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger();

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to AthleteApiDatasource');
  }

  /// GET /athletes — Backend max length for `search` is 100.
  Future<List<AthleteModel>> getAthletes({
    required String status,
    required String sort,
    required String direction,
    String? search,
    bool? hasProgram,
  }) async {
    final query = <String, String>{
      'status': status,
      'sort': sort,
      'direction': direction,
    };
    final term = search?.trim() ?? '';
    if (term.isNotEmpty) {
      query['search'] = term.length > 100 ? term.substring(0, 100) : term;
    }
    if (hasProgram != null) query['hasProgram'] = hasProgram ? 'true' : 'false';

    final qs = query.entries
        .map(
          (e) =>
              '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
        )
        .join('&');

    _logger.debug('AthleteDataSource: fetching athletes ($qs)');
    final data = await client.get('/athletes?$qs') as List<dynamic>;
    return data
        .map((j) => AthleteModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<AthleteSummaryModel> getSummary() async {
    final data = await client.get('/athletes/summary') as Map<String, dynamic>;
    return AthleteSummaryModel.fromJson(data);
  }

  Future<AthleteModel> getAthlete(String id) async {
    final data = await client.get('/athletes/$id') as Map<String, dynamic>;
    return AthleteModel.fromJson(data);
  }

  Future<AthleteModel> createAthlete(AthleteModel athlete) async {
    _logger.debug('AthleteDataSource: creating athlete');
    final data =
        await client.post('/athletes', athlete.toRequestJson())
            as Map<String, dynamic>;
    return AthleteModel.fromJson(data);
  }

  Future<AthleteModel> updateAthlete(AthleteModel athlete) async {
    _logger.debug('AthleteDataSource: updating athlete ${athlete.id}');
    final data =
        await client.put('/athletes/${athlete.id}', athlete.toRequestJson())
            as Map<String, dynamic>;
    return AthleteModel.fromJson(data);
  }

  Future<AthleteModel> archiveAthlete(String id) async {
    final data =
        await client.post('/athletes/$id/archive', const {})
            as Map<String, dynamic>;
    return AthleteModel.fromJson(data);
  }

  Future<AthleteModel> restoreAthlete(String id) async {
    final data =
        await client.post('/athletes/$id/restore', const {})
            as Map<String, dynamic>;
    return AthleteModel.fromJson(data);
  }

  Future<List<AthleteProgramAssignmentModel>> getProgramHistory(
    String athleteId,
  ) async {
    final data =
        await client.get('/athletes/$athleteId/program-history')
            as List<dynamic>;
    return data
        .map(
          (j) =>
              AthleteProgramAssignmentModel.fromJson(j as Map<String, dynamic>),
        )
        .toList();
  }

  Future<AthleteProgramAssignmentModel> assignProgram(
    String athleteId,
    String sourceProgramId,
    String? title,
  ) async {
    final body = <String, dynamic>{'sourceProgramId': sourceProgramId};
    if (title != null && title.trim().isNotEmpty) body['title'] = title.trim();
    final data =
        await client.post('/athletes/$athleteId/program-assignments', body)
            as Map<String, dynamic>;
    return AthleteProgramAssignmentModel.fromJson(data);
  }
}
