import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_filter.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_summary.dart';
import 'package:coach_studio/features/athlete/domain/repositories/athlete_repository.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AthleteCubit extends Cubit<AthleteState> {
  final AthleteRepository repository;
  final AppLogger _logger;

  AthleteFilter _filter = const AthleteFilter();
  int _requestId = 0;

  AthleteCubit({required this.repository, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger(),
      super(AthleteInitial());

  static AppLogger _createDefaultLogger() =>
      throw StateError('AppLogger must be provided to AthleteCubit');

  AthleteFilter get filter => _filter;

  Future<void> loadAthletes() => _load(showLoading: true);

  /// Silent reload (keeps current content / the mounted search field).
  Future<void> refresh() => _load(showLoading: false);

  Future<void> applyFilter(AthleteFilter filter) {
    _filter = filter;
    return _load(showLoading: false);
  }

  void reset() {
    _requestId++;
    _filter = const AthleteFilter();
    emit(AthleteInitial());
  }

  /// Returns null on success, otherwise a user-presentable error message.
  Future<String?> createAthlete(Athlete athlete) =>
      _mutate(() => repository.createAthlete(athlete));

  Future<String?> updateAthlete(Athlete athlete) =>
      _mutate(() => repository.updateAthlete(athlete));

  Future<String?> _mutate(Future<Object?> Function() action) async {
    try {
      await action();
    } on AppException catch (e) {
      return e.message;
    } catch (e) {
      _logger.error('AthleteCubit: unexpected mutation error', error: e);
      return e.toString();
    }
    await _load(showLoading: false);
    return null;
  }

  /// The summary is a secondary, best-effort call: it never fails the list.
  Future<AthleteSummary?> _loadSummary() async {
    try {
      return await repository.getSummary();
    } catch (e) {
      _logger.warning('AthleteCubit: failed to load summary', error: e);
      return null;
    }
  }

  Future<void> _load({required bool showLoading}) async {
    final requestId = ++_requestId;
    if (showLoading) emit(AthleteLoading());
    try {
      final summaryFuture = _loadSummary(); // never throws
      final athletes = await repository.getAthletes(_filter);
      final summary = await summaryFuture;
      if (requestId != _requestId) return; // stale response
      emit(AthleteLoaded(athletes: athletes, summary: summary));
    } on AppException catch (e) {
      if (requestId != _requestId) return;
      emit(AthleteError(e.message));
    } catch (e) {
      if (requestId != _requestId) return;
      _logger.error(
        'AthleteCubit: unexpected error loading athletes',
        error: e,
      );
      emit(AthleteError(e.toString()));
    }
  }
}
