import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';

sealed class AuthState {}

/// Before session restoration has been attempted.
class AuthInitial extends AuthState {}

/// Session restoration in progress (app startup only).
class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AuthUser user;

  AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}
