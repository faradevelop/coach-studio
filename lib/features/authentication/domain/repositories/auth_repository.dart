import 'package:coach_studio/features/authentication/domain/entities/auth_session.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';

abstract class AuthRepository {
  /// POST /auth/login — `identifier` accepts either a username or an
  /// email, exactly as the Backend's `AuthService::login` resolves it.
  Future<AuthSession> login(String identifier, String password);

  /// POST /auth/logout — revokes the current token.
  Future<void> logout();

  /// GET /auth/me — returns the currently authenticated user.
  Future<AuthUser> getCurrentUser();

  /// POST /auth/change-password — the Backend revokes ALL of the user's
  /// tokens on success.
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
  );

  /// POST /auth/forgot-password — always "succeeds" from the client's
  /// point of view (the Backend intentionally never reveals whether the
  /// email exists).
  Future<void> forgotPassword(String email);

  /// POST /auth/reset-password — the Backend revokes ALL of the user's
  /// tokens on success.
  Future<void> resetPassword(
    String email,
    String token,
    String password,
    String passwordConfirmation,
  );
}
