import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/features/authentication/data/models/auth_user_model.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';

class CoachApiDatasource {
  final ApiClient client;
  final AppLogger _logger;

  CoachApiDatasource({required this.client, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger();

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to CoachApiDatasource');
  }

  Future<List<AuthUserModel>> getCoaches() async {
    _logger.debug('CoachDataSource: fetching coaches');
    final data = await client.get('/users?role=coach') as List<dynamic>;
    return data
        .map((j) => AuthUserModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> createCoach({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _logger.debug('CoachDataSource: creating coach');
    // NOTE: never log the password.
    await client.post('/users', {
      'username': username,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': 'coach',
    });
  }

  /// Deactivation = DELETE /users/{id} (Backend never hard-deletes).
  /// Activation = PUT with isActive=true (the update endpoint needs the full profile).
  Future<void> setActive(AuthUser coach, bool active) async {
    _logger.debug('CoachDataSource: setActive(${coach.id}, $active)');
    if (active) {
      await client.put('/users/${coach.id}', {
        'username': coach.username,
        'email': coach.email,
        'role': coach.role.name,
        'isActive': true,
      });
    } else {
      await client.delete('/users/${coach.id}');
    }
  }
}
