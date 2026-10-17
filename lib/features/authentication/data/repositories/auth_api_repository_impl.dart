import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/authentication/data/datasources/auth_api_datasource.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_session.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';
import 'package:coach_studio/features/authentication/domain/repositories/auth_repository.dart';

class AuthApiRepositoryImpl implements AuthRepository {
  final AuthApiDatasource datasource;
  final AppLogger _logger;

  AuthApiRepositoryImpl({required this.datasource, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger();

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to AuthApiRepositoryImpl');
  }

  @override
  Future<AuthSession> login(String identifier, String password) async {
    _logger.info('AuthRepository: login started');
    try {
      final result = await datasource.login(identifier, password);
      _logger.info('AuthRepository: login successful');
      return AuthSession(user: result.user.toEntity(), token: result.token);
    } on ApiException catch (e) {
      _logger.error('AuthRepository: login failed', error: e.message);
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error('AuthRepository: unexpected login error', error: e);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    _logger.info('AuthRepository: logout started');
    try {
      await datasource.logout();
      _logger.info('AuthRepository: logout successful');
    } on ApiException catch (e) {
      _logger.error('AuthRepository: logout failed', error: e.message);
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error('AuthRepository: unexpected logout error', error: e);
      rethrow;
    }
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    _logger.debug('AuthRepository: fetching current user');
    try {
      final model = await datasource.getCurrentUser();
      _logger.debug('AuthRepository: current user retrieved');
      return model.toEntity();
    } on ApiException catch (e) {
      _logger.error(
        'AuthRepository: failed to fetch current user',
        error: e.message,
      );
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'AuthRepository: unexpected error fetching current user',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    _logger.info('AuthRepository: password change started');
    try {
      await datasource.changePassword(
        currentPassword,
        newPassword,
        newPasswordConfirmation,
      );
      _logger.info('AuthRepository: password changed successfully');
    } on ApiException catch (e) {
      _logger.error('AuthRepository: password change failed', error: e.message);
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'AuthRepository: unexpected password change error',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    _logger.info('AuthRepository: forgot password requested');
    try {
      await datasource.forgotPassword(email);
      _logger.info('AuthRepository: forgot password email sent');
    } on ApiException catch (e) {
      _logger.error('AuthRepository: forgot password failed', error: e.message);
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'AuthRepository: unexpected forgot password error',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String token,
    String password,
    String passwordConfirmation,
  ) async {
    _logger.info('AuthRepository: password reset started');
    try {
      await datasource.resetPassword(
        email,
        token,
        password,
        passwordConfirmation,
      );
      _logger.info('AuthRepository: password reset successful');
    } on ApiException catch (e) {
      _logger.error('AuthRepository: password reset failed', error: e.message);
      throw ApiException.mapApiException(e);
    } catch (e) {
      _logger.error(
        'AuthRepository: unexpected password reset error',
        error: e,
      );
      rethrow;
    }
  }
}
