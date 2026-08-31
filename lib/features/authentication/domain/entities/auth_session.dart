import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';

/// Result of a successful login: the authenticated user plus the Sanctum
/// bearer token issued for this session.
class AuthSession {
  final AuthUser user;
  final String token;

  const AuthSession({required this.user, required this.token});
}
