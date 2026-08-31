import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/storage/token_storage.dart';
import 'package:coach_studio/features/authentication/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository repository;
  final TokenStorage tokenStorage;

  AuthCubit({required this.repository, required this.tokenStorage})
    : super(AuthInitial());

  /// Restores the session on app startup: if a token was persisted from a
  /// previous run, validates it against GET /auth/me and hydrates the
  /// authenticated user. Otherwise (or if the token is no longer valid)
  /// the app starts unauthenticated.
  Future<void> restoreSession() async {
    emit(AuthLoading());

    final token = tokenStorage.token;
    if (token == null || token.isEmpty) {
      emit(AuthUnauthenticated());
      return;
    }

    try {
      final user = await repository.getCurrentUser();
      emit(AuthAuthenticated(user));
    } on UnauthenticatedException {
      await tokenStorage.clearToken();
      emit(AuthUnauthenticated());
    } catch (_) {
      // Non-auth failure (e.g. network) while restoring — don't destroy a
      // possibly-still-valid token, just fall back to the login screen.
      emit(AuthUnauthenticated());
    }
  }

  Future<bool> login(String identifier, String password) async {
    try {
      final session = await repository.login(identifier, password);
      await tokenStorage.saveToken(session.token);
      emit(AuthAuthenticated(session.user));
      return true;
    } catch (_) {
      emit(AuthUnauthenticated());
      return false;
    }
  }

  /// Revokes the current token on the Backend, then ALWAYS clears the
  /// local session — even if the Backend call fails (e.g. the token was
  /// already invalid/expired and the server responds 401) — so the user
  /// is never left stuck in an authenticated state on the client.
  Future<void> logout() async {
    try {
      await repository.logout();
    } catch (_) {
      // Ignored — the local session is cleared unconditionally below.
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
    if (state is! AuthAuthenticated) return false;

    try {
      await repository.changePassword(
        currentPassword,
        newPassword,
        newPasswordConfirmation,
      );
    } catch (_) {
      return false;
    }

    await tokenStorage.clearToken();
    emit(AuthUnauthenticated());
    return true;
  }

  Future<bool> forgotPassword(String email) async {
    try {
      await repository.forgotPassword(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String token,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      await repository.resetPassword(
        email,
        token,
        password,
        passwordConfirmation,
      );
      return true;
    } catch (_) {
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
      tokenStorage.clearToken();
      emit(AuthUnauthenticated());
    }
  }
}
