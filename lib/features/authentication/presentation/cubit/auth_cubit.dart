import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/storage/token_storage.dart';
import 'package:coach_studio/features/authentication/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final TokenStorage tokenStorage;
  final AppLogger _logger;

  AuthCubit({
    required this.repository,
    required this.tokenStorage,
    AppLogger? logger,
  }) : _logger = logger ?? _createDefaultLogger(),
       super(AuthInitial());

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to AuthCubit');
  }

  /// Restores the session on app startup: if a token was persisted from a
  /// previous run, validates it against GET /auth/me and hydrates the
  /// authenticated user. Otherwise (or if the token is no longer valid)
  /// the app starts unauthenticated.
  Future<void> restoreSession() async {
    _logger.debug('AuthCubit: session restoration started');
    emit(AuthLoading());

    final token = tokenStorage.token;
    if (token == null || token.isEmpty) {
      _logger.debug('AuthCubit: no token found — starting unauthenticated');
      emit(AuthUnauthenticated());
      return;
    }

    try {
      final user = await repository.getCurrentUser();
      _logger.info('AuthCubit: session restored for user');
      emit(AuthAuthenticated(user));
    } on UnauthenticatedException {
      _logger.warning('AuthCubit: token is invalid — clearing session');
      await tokenStorage.clearToken();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Non-auth failure (e.g. network) while restoring — don't destroy a
      // possibly-still-valid token, just fall back to the login screen.
      _logger.warning(
        'AuthCubit: non-auth error during session restoration',
        error: e,
      );
      emit(AuthUnauthenticated());
    }
  }

  Future<bool> login(String identifier, String password) async {
    _logger.info('AuthCubit: login started');
    try {
      final session = await repository.login(identifier, password);
      await tokenStorage.saveToken(session.token);
      _logger.info('AuthCubit: login successful');
      emit(AuthAuthenticated(session.user));
      return true;
    } catch (e) {
      _logger.error('AuthCubit: login failed', error: e);
      emit(AuthUnauthenticated());
      return false;
    }
  }

  /// Revokes the current token on the Backend, then ALWAYS clears the
  /// local session — even if the Backend call fails (e.g. the token was
  /// already invalid/expired and the server responds 401) — so the user
  /// is never left stuck in an authenticated state on the client.
  Future<void> logout() async {
    _logger.info('AuthCubit: logout started');
    try {
      await repository.logout();
      _logger.info('AuthCubit: logout successful');
    } catch (e) {
      // Ignored — the local session is cleared unconditionally below.
      _logger.warning('AuthCubit: logout API call failed', error: e);
    } finally {
      await tokenStorage.clearToken();
      emit(AuthUnauthenticated());
    }
  }

  /// Changes the password. The Backend revokes ALL Sanctum tokens for the
  /// user when this succeeds (including the one currently in use), so on
  /// success the local session is cleared too and the user is returned to
  /// the login screen.
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    _logger.info('AuthCubit: password change started');
    if (state is! AuthAuthenticated) {
      _logger.warning(
        'AuthCubit: password change called while unauthenticated',
      );
      return false;
    }

    try {
      await repository.changePassword(
        currentPassword,
        newPassword,
        newPasswordConfirmation,
      );
      _logger.info('AuthCubit: password changed successfully');
    } catch (e) {
      _logger.error('AuthCubit: password change failed', error: e);
      return false;
    }

    await tokenStorage.clearToken();
    emit(AuthUnauthenticated());
    return true;
  }

  Future<bool> forgotPassword(String email) async {
    _logger.info('AuthCubit: forgot password requested');
    try {
      await repository.forgotPassword(email);
      _logger.info('AuthCubit: forgot password email sent');
      return true;
    } catch (e) {
      _logger.error('AuthCubit: forgot password failed', error: e);
      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String token,
    String password,
    String passwordConfirmation,
  ) async {
    _logger.info('AuthCubit: password reset started');
    try {
      await repository.resetPassword(
        email,
        token,
        password,
        passwordConfirmation,
      );
      _logger.info('AuthCubit: password reset successful');
      return true;
    } catch (e) {
      _logger.error('AuthCubit: password reset failed', error: e);
      return false;
    }
  }

  /// Called from `ApiClient.onUnauthorized` whenever ANY authenticated
  /// request comes back with 401 (e.g. the token was revoked server-side
  /// by a password change/reset from another device/session). Forces the
  /// app back to the unauthenticated state so the router redirects to
  /// login.
  void handleUnauthorized() {
    if (state is AuthAuthenticated) {
      _logger.warning('AuthCubit: unauthorized (401) — forcing logout');
      tokenStorage.clearToken();
      emit(AuthUnauthenticated());
    }
  }
}
