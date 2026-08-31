import 'dart:async';

import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutProgramCubit extends Cubit<WorkoutProgramState> {
  final WorkoutProgramRepository repository;
  final AppLogger _logger;

  StreamSubscription<List<WorkoutProgram>>? _subscription;

  WorkoutProgramCubit({required this.repository, AppLogger? logger})
    : _logger = logger ?? _createDefaultLogger(),
      super(WorkoutProgramInitial());

  static AppLogger _createDefaultLogger() {
    throw StateError('AppLogger must be provided to WorkoutProgramCubit');
  }

  void loadPrograms() {
    _logger.debug('WorkoutProgramCubit: loading programs');
    emit(WorkoutProgramLoading());

    _subscription?.cancel();

    _subscription = repository.watchPrograms().listen((programs) {
      _logger.info(
        'WorkoutProgramCubit: programs loaded (${programs.length} items)',
      );
      emit(WorkoutProgramLoaded(programs));
    }, onError: _handleError);
  }

  Future<void> _refreshPrograms() async {
    final programs = await repository.watchPrograms().first;

    emit(WorkoutProgramLoaded(programs));
  }

  Future<WorkoutProgram?> addProgram(WorkoutProgram program) async {
    _logger.info('WorkoutProgramCubit: adding program');
    WorkoutProgram? createdProgram;

    // Mutation
    try {
      createdProgram = await repository.addProgram(program);

      if (createdProgram == null) {
        _logger.error('WorkoutProgramCubit: failed to add program');
        return null;
      }
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: error adding program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return null;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error adding program',
        error: e,
      );
      emit(WorkoutProgramError(e.toString()));
      return null;
    }

    // Refresh
    try {
      await _refreshPrograms();
      _logger.info('WorkoutProgramCubit: program added successfully');
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after adding program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
    } catch (_) {
      _logger.error('WorkoutProgramCubit: refresh failed after adding program');
      emit(WorkoutProgramError('Refresh Failed!'));
    }

    return createdProgram;
  }

  Future<bool> updateProgram(WorkoutProgram program) async {
    _logger.info('WorkoutProgramCubit: updating program ${program.id}');
    // Mutation
    try {
      final success = await repository.updateProgram(program);

      if (!success) {
        _logger.error('WorkoutProgramCubit: failed to update program');
        return false;
      }
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: error updating program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error updating program',
        error: e,
      );
      emit(WorkoutProgramError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshPrograms();
      _logger.info('WorkoutProgramCubit: program updated successfully');
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after updating program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
    } catch (_) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after updating program',
      );
      emit(WorkoutProgramError('Refresh Failed!'));
    }

    return true;
  }

  Future<bool> deleteProgram(String id) async {
    _logger.info('WorkoutProgramCubit: deleting program $id');
    // Mutation
    try {
      final success = await repository.deleteProgram(id);

      if (!success) {
        _logger.error('WorkoutProgramCubit: failed to delete program');
        return false;
      }
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: error deleting program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error deleting program',
        error: e,
      );
      emit(WorkoutProgramError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshPrograms();
      _logger.info('WorkoutProgramCubit: program deleted successfully');
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after deleting program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
    } catch (_) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after deleting program',
      );
      emit(WorkoutProgramError('Refresh Failed!'));
    }

    return true;
  }

  Future<bool> duplicateProgram(String id, String title) async {
    _logger.info('WorkoutProgramCubit: duplicating program $id');
    // Mutation
    try {
      final success = await repository.duplicateProgram(id, title);

      if (!success) {
        _logger.error('WorkoutProgramCubit: failed to duplicate program');
        return false;
      }
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: error duplicating program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (e) {
      _logger.error(
        'WorkoutProgramCubit: unexpected error duplicating program',
        error: e,
      );
      emit(WorkoutProgramError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshPrograms();
      _logger.info('WorkoutProgramCubit: program duplicated successfully');
    } on AppException catch (e) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after duplicating program',
        error: e.message,
      );
      emit(WorkoutProgramError(e.message));
    } catch (_) {
      _logger.error(
        'WorkoutProgramCubit: refresh failed after duplicating program',
      );
      emit(WorkoutProgramError('Refresh Failed!'));
    }

    return true;
  }

  void _handleError(Object error) {
    if (error is AppException) {
      _logger.error(
        'WorkoutProgramCubit: error in watch stream',
        error: error.message,
      );
      emit(WorkoutProgramError(error.message));
      return;
    }

    _logger.error(
      'WorkoutProgramCubit: unexpected error in watch stream',
      error: error,
    );
    emit(WorkoutProgramError(error.toString()));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();

    return super.close();
  }
}
