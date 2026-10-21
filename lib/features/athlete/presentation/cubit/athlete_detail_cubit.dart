import 'dart:async';

import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/athlete/domain/repositories/athlete_repository.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_cubit.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AthleteDetailCubit extends Cubit<AthleteDetailState> {
  final String athleteId;
  final AthleteRepository repository;
  final AthleteCubit listCubit;
  final AppLogger _logger;

  AthleteDetailCubit({
    required this.athleteId,
    required this.repository,
    required this.listCubit,
    required AppLogger logger,
  }) : _logger = logger,
       super(AthleteDetailLoading());

  /// [silent] keeps the current content visible while reloading.
  Future<void> load({bool silent = false}) async {
    if (!silent || state is! AthleteDetailLoaded) emit(AthleteDetailLoading());
    try {
      final athlete = await repository.getAthlete(athleteId);
      final history = await repository.getProgramHistory(athleteId);
      emit(AthleteDetailLoaded(athlete: athlete, history: history));
    } on AppException catch (e) {
      emit(AthleteDetailError(e.message));
    } catch (e) {
      _logger.error('AthleteDetailCubit: unexpected load error', error: e);
      emit(AthleteDetailError(e.toString()));
    }
  }

  Future<String?> archive() =>
      _mutate(() => repository.archiveAthlete(athleteId));

  Future<String?> restore() =>
      _mutate(() => repository.restoreAthlete(athleteId));

  Future<String?> assignProgram(String sourceProgramId, String? title) =>
      _mutate(
        () =>
            repository.assignProgram(athleteId, sourceProgramId, title: title),
      );

  /// Returns null on success, otherwise a user-presentable message.
  Future<String?> _mutate(Future<Object?> Function() action) async {
    final current = state;
    if (current is! AthleteDetailLoaded || current.isSubmitting) {
      return 'درخواست قبلی هنوز در حال انجام است.';
    }
    emit(current.copyWith(isSubmitting: true));
    try {
      await action();
    } on AppException catch (e) {
      emit(current.copyWith(isSubmitting: false));
      return e.message;
    } catch (e) {
      _logger.error('AthleteDetailCubit: unexpected mutation error', error: e);
      emit(current.copyWith(isSubmitting: false));
      return e.toString();
    }
    await load(silent: true);
    unawaited(listCubit.refresh());
    return null;
  }
}
