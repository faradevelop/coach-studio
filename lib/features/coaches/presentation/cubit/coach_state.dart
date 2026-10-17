import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';

sealed class CoachState {}

class CoachInitial extends CoachState {}

class CoachLoading extends CoachState {}

class CoachLoaded extends CoachState {
  final List<AuthUser> coaches;
  CoachLoaded(this.coaches);
}

class CoachError extends CoachState {
  final String message;
  CoachError(this.message);
}
