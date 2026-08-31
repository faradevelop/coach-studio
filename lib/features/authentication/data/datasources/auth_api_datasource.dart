import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/authentication/data/models/auth_user_model.dart';
import 'package:coach_studio/features/authentication/data/models/login_result_model.dart';

class AuthApiDatasource {
  final ApiClient client;

  AuthApiDatasource({required this.client});

  Future<LoginResultModel> login(String identifier, String password) async {
    final data =
        await client.post('/auth/login', {
              'identifier': identifier,
              'password': password,
            })
            as Map<String, dynamic>;

    return LoginResultModel.fromJson(data);
  }

  Future<void> logout() async {
    try {
      await client.post('/auth/logout', const {});
    } on ApiException catch (e) {
      // The token was already invalid/expired server-side — from the
      // client's perspective this is already "logged out", not an error.
      if (e.statusCode == 401) return;
      rethrow;
    }
  }

  Future<AuthUserModel> getCurrentUser() async {
    final data = await client.get('/auth/me') as Map<String, dynamic>;
    return AuthUserModel.fromJson(data);
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    await client.post('/auth/change-password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      // Laravel's `confirmed` rule expects exactly "<field>_confirmation".
      'newPassword_confirmation': newPasswordConfirmation,
    });
  }

  Future<void> forgotPassword(String email) async {
    await client.post('/auth/forgot-password', {'email': email});
  }

  Future<void> resetPassword(
    String email,
    String token,
    String password,
    String passwordConfirmation,
  ) async {
    await client.post('/auth/reset-password', {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }
}
