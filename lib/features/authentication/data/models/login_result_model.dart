import 'package:coach_studio/features/authentication/data/models/auth_user_model.dart';

/// Maps the `data` payload of `POST /auth/login`: `{ user, token }`.
class LoginResultModel {
  final AuthUserModel user;
  final String token;

  const LoginResultModel({required this.user, required this.token});

  factory LoginResultModel.fromJson(Map<String, dynamic> json) {
    return LoginResultModel(
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}
