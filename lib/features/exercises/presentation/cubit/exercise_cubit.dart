import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise_filter.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  static const _unexpectedMessage =
      'خطای غیرمنتظره‌ای رخ داد. دوباره تلاش کنید.';

  final ExerciseRepository repository;
  final AppLogger _logger;

  List<Muscle> _muscles = [];
  bool _metaLoaded = false;
  Future<bool>? _metaFuture;
  ExerciseFilter _filter = const ExerciseFilter();
  int _requestId = 0;

  /// Size of the UNFILTERED active-exercise catalog, or null if it has not
  /// been loaded yet. [ExerciseLoaded.exercises] is the *filtered* list, so
  /// it can't be used for totals while a search/filter is applied. Updated
  /// on every unfiltered load, and adjusted by ±1 on add/delete so it stays
  /// correct even if a mutation happens while a filter is active.
  int? _totalExercises;

  List<Muscle> get muscles => _muscles;
  bool get isMetaLoaded => _metaLoaded;
  ExerciseFilter get filter => _filter;
  int? get totalExercises => _totalExercises;

  ExerciseCubit({required this.repository, required this._logger})
    : super(ExerciseInitial()) {
    ensureMetaLoaded();
  }

  /// Loads stable metadata (muscles). Retryable; never throws.
  Future<bool> ensureMetaLoaded() {
    if (_metaLoaded) return Future.value(true);
    return _metaFuture ??= _loadMeta();
  }

  Future<bool> _loadMeta() async {
    try {
      _muscles = await repository.getMuscles();
      _metaLoaded = true;
      return true;
    } catch (e) {
      _logger.error(
        'ExerciseCubit: failed to load exercise metadata',
        error: e,
      );
      return false;
    } finally {
      _metaFuture = null;
    }
  }

  Future<List<Exercise>> _search(ExerciseFilter f) =>
      repository.searchExercises(
        search: f.search,
        type: f.type?.name,
        difficulty: f.difficulty?.name,
        equipment: f.equipment?.name,
        muscleSlugs: f.muscles.map((m) => m.slug).toList(),
      );

  Future<void> loadExercises() => _load(showLoading: true);

  /// Server-side search/filter for the shared list state (list page).
  Future<void> applyFilter(ExerciseFilter filter) {
    _filter = filter;
    return _load(
      showLoading: false,
    ); // no Loading state: keeps the search field mounted
  }

  /// Stateless server-side query (wizard). Does not touch list state or [filter].
  Future<List<Exercise>> searchExercises(ExerciseFilter filter) =>
      _search(filter);

  void _syncTotal(List<Exercise> exercises) {
    if (_filter.isEmpty) _totalExercises = exercises.length;
  }

  void _adjustTotal(int delta) {
    final total = _totalExercises;
    if (total == null) return;
    final next = total + delta;
    _totalExercises = next < 0 ? 0 : next;
  }

  Future<void> _load({required bool showLoading}) async {
    _logger.debug('ExerciseCubit: loading exercises');
    final requestId = ++_requestId;
    if (showLoading) emit(ExerciseLoading());
    try {
      final exercises = await _search(_filter);
      if (requestId != _requestId) return; // stale response
      _syncTotal(exercises);
      emit(ExerciseLoaded(exercises: exercises));
    } on AppException catch (e) {
      if (requestId != _requestId) return;
      _logger.error(
        'ExerciseCubit: failed to load exercises',
        error: e.message,
      );
      emit(ExerciseError(e.message));
    } catch (e) {
      if (requestId != _requestId) return;
      _logger.error(
        'ExerciseCubit: unexpected error loading exercises',
        error: e,
      );
      emit(ExerciseError(_unexpectedMessage));
    }
  }

  /// Mutations refresh with the ACTIVE filter, so add/edit/delete doesn't
  /// drop the search. Throws on failure.
  Future<void> _refreshExercises() async {
    final requestId = ++_requestId;
    final exercises = await _search(_filter);
    if (requestId != _requestId) return;
    _syncTotal(exercises);
    emit(ExerciseLoaded(exercises: exercises));
  }

  Future<bool> addExercise(Exercise exercise) => _mutate(
    action: 'add exercise',
    run: () => repository.addExercise(exercise),
    totalDelta: 1,
  );

  Future<bool> updateExercise(Exercise exercise) => _mutate(
    action: 'update exercise ${exercise.id}',
    run: () => repository.updateExercise(exercise),
  );

  Future<bool> deleteExercise(String id) => _mutate(
    action: 'delete exercise $id',
    run: () => repository.deleteExercise(id),
    totalDelta: -1,
  );

  /// A failed mutation (validation, forbidden, network...) restores the
  /// existing list instead of switching the whole page to Error. A failed
  /// refresh after a successful mutation is only logged.
  Future<bool> _mutate({
    required String action,
    required Future<void> Function() run,
    int totalDelta = 0,
  }) async {
    final current = state;

    if (current is! ExerciseLoaded || current.isSubmitting) {
      _logger.warning(
        'ExerciseCubit: cannot $action — not loaded or already submitting',
      );
      return false;
    }

    emit(current.copyWith(isSubmitting: true));

    try {
      await run();
    } on AppException catch (e) {
      _logger.error('ExerciseCubit: failed to $action', error: e.message);
      _endSubmitting();
      return false;
    } catch (e) {
      _logger.error('ExerciseCubit: unexpected error ($action)', error: e);
      _endSubmitting();
      return false;
    }

    if (totalDelta != 0) _adjustTotal(totalDelta);

    try {
      await _refreshExercises();
    } catch (e) {
      _logger.error('ExerciseCubit: refresh failed after $action', error: e);
    }

    _endSubmitting(); // no-op unless the refresh failed or was superseded
    return true;
  }

  void _endSubmitting() {
    final s = state;
    if (s is ExerciseLoaded && s.isSubmitting) {
      emit(s.copyWith(isSubmitting: false));
    }
  }
}
