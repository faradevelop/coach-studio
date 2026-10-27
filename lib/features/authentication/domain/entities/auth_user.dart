import 'package:coach_studio/features/authentication/domain/enums/user_role.dart';

class AuthUser {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final UserRole role;
  final bool isActive;

  const AuthUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    required this.role,
    required this.isActive,
  });

  String get fullName => '$firstName $lastName'.trim();

  /// Full name, falling back to the username for legacy users that were
  /// created before first/last name existed.
  String get displayName => fullName.isEmpty ? username : fullName;

  bool get isAdmin => role == UserRole.admin;
  bool get isCoach => role == UserRole.coach;
}
