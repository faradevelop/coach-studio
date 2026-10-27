import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';

abstract class CoachRepository {
  Future<List<AuthUser>> getCoaches();

  Future<void> createCoach({
    required String username,
    required String firstName,
    required String lastName,
    required String phone,
    String? email,
    required String password,
    required String passwordConfirmation,
  });

  Future<void> setCoachActive(AuthUser coach, bool active);
}
