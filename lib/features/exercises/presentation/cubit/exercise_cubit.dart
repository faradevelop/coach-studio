import 'dart:async';

import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise_filter.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExerciseCubit extends Cubit<ExerciseState> {
  final ExerciseRepository repository;
  final AppLogger _logger;

  List<Muscle> _muscles = [];
  bool _metaLoaded = false;
  Future<bool>? _metaFuture;
  ExerciseFilter _filter = const ExerciseFilter();
  int _requestId = 0;

  List<Muscle> get muscles => _muscles;
  bool get isMetaLoaded => _metaLoaded;
  ExerciseFilter get filter => _filter;

  ExerciseCubit({required this.repository, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger(),
      super(ExerciseInitial()) {
    ensureMetaLoaded();
  }

  static AppLogger _createDefaultLogger() =>
      throw StateError('AppLogger must be provided to ExerciseCubit');

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

  Future<List<Exercise>?> _search(ExerciseFilter f) =>
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
  Future<List<Exercise>> searchExercises(ExerciseFilter filter) async {
    final result = await _search(filter);
    if (result == null) {
      throw const ValidationException('Invalid search parameters');
    }
    return result;
  }

  Future<void> _load({required bool showLoading}) async {
    _logger.debug('ExerciseCubit: loading exercises');
    final requestId = ++_requestId;
    if (showLoading) emit(ExerciseLoading());
    try {
      final exercises = await _search(_filter);
      if (requestId != _requestId) return; // stale response
      if (exercises == null) {
        emit(ExerciseError('Invalid request'));
        return;
      }
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
      emit(ExerciseError(e.toString()));
    }
  }

  // Mutations refresh with the ACTIVE filter, so add/edit/delete doesn't drop the search.
  Future<void> _refreshExercises() async {
    final requestId = ++_requestId;
    final exercises = await _search(_filter);
    if (requestId != _requestId) return;
    if (exercises == null) throw const ServerException('Refresh failed!');
    emit(ExerciseLoaded(exercises: exercises, isSubmitting: false));
  }

  Future<bool> addExercise(Exercise exercise) async {
    _logger.info('ExerciseCubit: adding exercise');
    final currentState = state;

    if (currentState is! ExerciseLoaded) {
      _logger.warning(
        'ExerciseCubit: cannot add exercise — not in loaded state',
      );
      return false;
    }

    emit(currentState.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.addExercise(exercise);

      if (!success) {
        _logger.error('ExerciseCubit: failed to add exercise');
        _restoreState(currentState);
        return false;
      }
    } on AppException catch (e) {
      _logger.error('ExerciseCubit: error adding exercise', error: e.message);
      emit(ExerciseError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'ExerciseCubit: unexpected error adding exercise',
        error: e,
      );
      emit(ExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
      _logger.info('ExerciseCubit: exercise added successfully');
    } on ForbiddenException catch (e) {
      _logger.warning('ExerciseCubit: add forbidden', error: e.message);
      _restoreState(currentState);
      return false;
    } on AppException catch (e) {
      _logger.error(
        'ExerciseCubit: refresh failed after adding exercise',
        error: e.message,
      );
      emit(ExerciseError(e.message));
    } catch (_) {
      _logger.error('ExerciseCubit: refresh failed after adding exercise');
      emit(ExerciseError('Refresh failed!'));
    }

    return true;
  }

  Future<bool> updateExercise(Exercise exercise) async {
    _logger.info('ExerciseCubit: updating exercise ${exercise.id}');
    final currentState = state;

    if (currentState is! ExerciseLoaded) {
      _logger.warning(
        'ExerciseCubit: cannot update exercise — not in loaded state',
      );
      return false;
    }

    emit(currentState.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.updateExercise(exercise);

      if (!success) {
        _logger.error('ExerciseCubit: failed to update exercise');
        _restoreState(currentState);
        return false;
      }
    } on ForbiddenException catch (e) {
      _logger.warning('ExerciseCubit: update forbidden', error: e.message);
      _restoreState(currentState);
      return false;
    } on AppException catch (e) {
      _logger.error('ExerciseCubit: error updating exercise', error: e.message);
      emit(ExerciseError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'ExerciseCubit: unexpected error updating exercise',
        error: e,
      );
      emit(ExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
      _logger.info('ExerciseCubit: exercise updated successfully');
    } on AppException catch (e) {
      _logger.error(
        'ExerciseCubit: refresh failed after updating exercise',
        error: e.message,
      );
      emit(ExerciseError(e.message));
    } catch (_) {
      _logger.error('ExerciseCubit: refresh failed after updating exercise');
      emit(ExerciseError('Refresh failed!'));
    }

    return true;
  }

  Future<bool> deleteExercise(String id) async {
    _logger.info('ExerciseCubit: deleting exercise $id');
    final currentState = state;

    if (currentState is! ExerciseLoaded) {
      _logger.warning(
        'ExerciseCubit: cannot delete exercise — not in loaded state',
      );
      return false;
    }

    emit(currentState.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.deleteExercise(id);

      if (!success) {
        _logger.error('ExerciseCubit: failed to delete exercise');
        _restoreState(currentState);
        return false;
      }
    } on ForbiddenException catch (e) {
      _logger.warning('ExerciseCubit: delete forbidden', error: e.message);
      _restoreState(currentState);
      return false;
    } on AppException catch (e) {
      _logger.error('ExerciseCubit: error deleting exercise', error: e.message);
      emit(ExerciseError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'ExerciseCubit: unexpected error deleting exercise',
        error: e,
      );
      emit(ExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
      _logger.info('ExerciseCubit: exercise deleted successfully');
    } on AppException catch (e) {
      _logger.error(
        'ExerciseCubit: refresh failed after deleting exercise',
        error: e.message,
      );
      emit(ExerciseError(e.message));
    } catch (_) {
      _logger.error('ExerciseCubit: refresh failed after deleting exercise');
      emit(ExerciseError('Refresh failed!'));
    }

    return true;
  }

  void _restoreState(ExerciseLoaded previousState) {
    emit(previousState.copyWith(isSubmitting: false));
  }
}
