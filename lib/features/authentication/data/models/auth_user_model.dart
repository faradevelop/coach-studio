import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';
import 'package:coach_studio/features/authentication/domain/enums/user_role.dart';

class AuthUserModel {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String phone;
  final String? email;
  final UserRole role;
  final bool isActive;

  const AuthUserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.email,
    required this.role,
    required this.isActive,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: UserRole.values.byName(json['role'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      username: username,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      role: role,
      isActive: isActive,
    );
  }
}
