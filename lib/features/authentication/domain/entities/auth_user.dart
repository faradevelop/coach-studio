import 'package:coach_studio/features/authentication/domain/enums/user_role.dart';

class AuthUser {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final bool isActive;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.isActive,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isCoach => role == UserRole.coach;
}
