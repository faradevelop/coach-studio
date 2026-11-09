import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_session.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';
import 'package:coach_studio/features/authentication/domain/enums/user_role.dart';
import 'package:coach_studio/features/authentication/domain/repositories/auth_repository.dart';

class FakeLogger implements AppLogger {
  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {}
  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

AuthUser userFixture({UserRole role = UserRole.coach}) => AuthUser(
  id: 'u1',
  username: 'coach1',
  firstName: 'Ali',
  lastName: 'Rezaei',
  phone: '09121234567',
  role: role,
  isActive: true,
);

class FakeAuthRepository implements AuthRepository {
  Future<AuthSession> Function(String, String)? onLogin;
  int logoutCalls = 0;

  @override
  Future<AuthSession> login(String identifier, String password) =>
      onLogin!(identifier, password);

  @override
  Future<void> logout() async => logoutCalls++;

  @override
  Future<AuthUser> getCurrentUser() async => userFixture();

  @override
  Future<void> changePassword(String a, String b, String c) async {}

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword(String a, String b, String c, String d) async {}
}
