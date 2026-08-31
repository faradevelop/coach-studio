import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/authentication/data/datasources/auth_api_datasource.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_session.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';
import 'package:coach_studio/features/authentication/domain/repositories/auth_repository.dart';

class AuthApiRepositoryImpl implements AuthRepository {
  final AuthApiDatasource datasource;

  AuthApiRepositoryImpl({required this.datasource});

  @override
  Future<AuthSession> login(String identifier, String password) async {
    try {
      final result = await datasource.login(identifier, password);
      return AuthSession(user: result.user.toEntity(), token: result.token);
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await datasource.logout();
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    try {
      final model = await datasource.getCurrentUser();
      return model.toEntity();
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    try {
      await datasource.changePassword(
        currentPassword,
        newPassword,
        newPasswordConfirmation,
      );
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await datasource.forgotPassword(email);
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String token,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      await datasource.resetPassword(
        email,
        token,
        password,
        passwordConfirmation,
      );
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }
}
