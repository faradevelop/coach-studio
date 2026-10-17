import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';
import 'package:coach_studio/features/coaches/domain/repositories/coach_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'coach_state.dart';

class CoachCubit extends Cubit<CoachState> {
  final CoachRepository repository;
  final AppLogger _logger;

  CoachCubit({required this.repository, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger(),
      super(CoachInitial());

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to CoachCubit');
  }

  Future<void> load() async {
    emit(CoachLoading());
    await _fetch();
  }

  void reset() => emit(CoachInitial());

  /// Returns null on success, otherwise a user-presentable error message.
  Future<String?> createCoach({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) {
    return _mutate(
      () => repository.createCoach(
        username: username,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    );
  }

  Future<String?> setActive(AuthUser coach, bool active) =>
      _mutate(() => repository.setCoachActive(coach, active));

  Future<String?> _mutate(Future<void> Function() action) async {
    try {
      await action();
    } on AppException catch (e) {
      return e.message;
    } catch (e) {
      _logger.error('CoachCubit: unexpected mutation error', error: e);
      return e.toString();
    }
    // Refresh keeps the current list visible (no Loading flash).
    await _fetch();
    return null;
  }

  Future<void> _fetch() async {
    try {
      emit(CoachLoaded(await repository.getCoaches()));
    } on AppException catch (e) {
      emit(CoachError(e.message));
    } catch (e) {
      _logger.error('CoachCubit: unexpected error loading coaches', error: e);
      emit(CoachError(e.toString()));
    }
  }
}
