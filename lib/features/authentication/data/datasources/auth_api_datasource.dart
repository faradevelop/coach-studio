import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/authentication/data/models/auth_user_model.dart';
import 'package:coach_studio/features/authentication/data/models/login_result_model.dart';

class AuthApiDatasource {
  final ApiClient client;
  final AppLogger _logger;

  AuthApiDatasource({required this.client, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger();

  static AppLogger _createDefaultLogger() {
    // Fallback logger if not provided (shouldn't happen in normal flow)
    throw StateError('AppLogger must be provided to AuthApiDatasource');
  }

  Future<LoginResultModel> login(String identifier, String password) async {
    _logger.info('AuthDataSource: login started');
    try {
      final data =
          await client.post('/auth/login', {
                'identifier': identifier,
                // NOTE: Never log password for security
                'password': password,
              })
              as Map<String, dynamic>;

      final result = LoginResultModel.fromJson(data);
      _logger.info('AuthDataSource: login successful');
      return result;
    } catch (e) {
      _logger.error('AuthDataSource: login failed', error: e);
      rethrow;
    }
  }

  Future<void> logout() async {
    _logger.info('AuthDataSource: logout started');
    try {
      await client.post('/auth/logout', const {});
      _logger.info('AuthDataSource: logout successful');
    } on ApiException catch (e) {
      // The token was already invalid/expired server-side — from the
      // client's perspective this is already "logged out", not an error.
      if (e.statusCode == 401) {
        _logger.debug(
          'AuthDataSource: logout called with invalid token (expected)',
        );
        return;
      }
      _logger.error('AuthDataSource: logout failed', error: e);
      rethrow;
    }
  }

  Future<AuthUserModel> getCurrentUser() async {
    _logger.debug('AuthDataSource: fetching current user');
    try {
      final data = await client.get('/auth/me') as Map<String, dynamic>;
      _logger.debug('AuthDataSource: current user retrieved');
      return AuthUserModel.fromJson(data);
    } catch (e) {
      _logger.error('AuthDataSource: failed to fetch current user', error: e);
      rethrow;
    }
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    _logger.info('AuthDataSource: change password started');
    // NOTE: Never log passwords for security
    try {
      await client.post('/auth/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        // Laravel's `confirmed` rule expects exactly "<field>_confirmation".
        'newPassword_confirmation': newPasswordConfirmation,
      });
      _logger.info('AuthDataSource: password changed successfully');
    } catch (e) {
      _logger.error('AuthDataSource: password change failed', error: e);
      rethrow;
    }
  }

  Future<void> forgotPassword(String email) async {
    _logger.info('AuthDataSource: forgot password requested for email');
    try {
      await client.post('/auth/forgot-password', {'email': email});
      _logger.info('AuthDataSource: forgot password request sent');
    } catch (e) {
      _logger.error('AuthDataSource: forgot password failed', error: e);
      rethrow;
    }
  }

  Future<void> resetPassword(
    String email,
    String token,
    String password,
    String passwordConfirmation,
  ) async {
    _logger.info('AuthDataSource: reset password started');
    // NOTE: Never log passwords or reset tokens for security
    try {
      await client.post('/auth/reset-password', {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
      _logger.info('AuthDataSource: password reset successful');
    } catch (e) {
      _logger.error('AuthDataSource: password reset failed', error: e);
      rethrow;
    }
  }
}
