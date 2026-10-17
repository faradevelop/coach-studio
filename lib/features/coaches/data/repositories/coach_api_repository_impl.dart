import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';
import 'package:coach_studio/features/coaches/data/datasources/coach_api_datasource.dart';
import 'package:coach_studio/features/coaches/domain/repositories/coach_repository.dart';

class CoachApiRepositoryImpl implements CoachRepository {
  final CoachApiDatasource datasource;
  final AppLogger _logger;

  CoachApiRepositoryImpl({required this.datasource, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger();

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to CoachApiRepositoryImpl');
  }

  @override
  Future<List<AuthUser>> getCoaches() => _guard(
    'load coaches',
    () async =>
        (await datasource.getCoaches()).map((m) => m.toEntity()).toList(),
  );

  @override
  Future<void> createCoach({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) => _guard(
    'create coach',
    () => datasource.createCoach(
      username: username,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    ),
  );

  @override
  Future<void> setCoachActive(AuthUser coach, bool active) =>
      _guard('change coach status', () => datasource.setActive(coach, active));

  Future<T> _guard<T>(String action, Future<T> Function() run) async {
    try {
      return await run();
    } on ApiException catch (e) {
      _logger.error('CoachRepository: failed to $action', error: e.message);
      throw ApiException.mapApiException(_withFirstValidationMessage(e));
    } catch (e) {
      _logger.error('CoachRepository: unexpected error ($action)', error: e);
      rethrow;
    }
  }

  /// Surfaces Laravel's first field error ("The username has already been
  /// taken.") instead of the generic "Validation failed".
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
