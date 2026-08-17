import 'dart:async';

import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutProgramCubit extends Cubit<WorkoutProgramState> {
  final WorkoutProgramRepository repository;

  StreamSubscription<List<WorkoutProgram>>? _subscription;

  WorkoutProgramCubit({required this.repository})
    : super(WorkoutProgramInitial());

  void loadPrograms() {
    emit(WorkoutProgramLoading());

    _subscription?.cancel();

    _subscription = repository.watchPrograms().listen((programs) {
      emit(WorkoutProgramLoaded(programs));
    }, onError: _handleError);
  }

  Future<void> _refreshPrograms() async {
    final programs = await repository.watchPrograms().first;

    emit(WorkoutProgramLoaded(programs));
  }

  Future<WorkoutProgram?> addProgram(WorkoutProgram program) async {
    WorkoutProgram? createdProgram;

    // Mutation
    try {
      createdProgram = await repository.addProgram(program);

      if (createdProgram == null) {
        return null;
      }
    } on AppException catch (e) {
      emit(WorkoutProgramError(e.message));
      return null;
    } catch (e) {
      emit(WorkoutProgramError(e.toString()));
      return null;
    }

    // Refresh
    try {
      await _refreshPrograms();
    } on AppException catch (e) {
      emit(WorkoutProgramError(e.message));
    } catch (_) {
      emit(WorkoutProgramError('Refresh Failed!'));
    }

    return createdProgram;
  }

  Future<bool> updateProgram(WorkoutProgram program) async {
    // Mutation
    try {
      final success = await repository.updateProgram(program);

      if (!success) {
        return false;
      }
    } on AppException catch (e) {
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (e) {
      emit(WorkoutProgramError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshPrograms();
    } on AppException catch (e) {
      emit(WorkoutProgramError(e.message));
    } catch (_) {
      emit(WorkoutProgramError('Refresh Failed!'));
    }

    return true;
  }

  Future<bool> deleteProgram(String id) async {
    // Mutation
    try {
      final success = await repository.deleteProgram(id);

      if (!success) {
        return false;
      }
    } on AppException catch (e) {
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (e) {
      emit(WorkoutProgramError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshPrograms();
    } on AppException catch (e) {
      emit(WorkoutProgramError(e.message));
    } catch (_) {
      emit(WorkoutProgramError('Refresh Failed!'));
    }

    return true;
  }

  Future<bool> duplicateProgram(String id, String title) async {
    // Mutation
    try {
      final success = await repository.duplicateProgram(id, title);

      if (!success) {
        return false;
      }
    } on AppException catch (e) {
      emit(WorkoutProgramError(e.message));
      return false;
    } catch (e) {
      emit(WorkoutProgramError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshPrograms();
    } on AppException catch (e) {
      emit(WorkoutProgramError(e.message));
    } catch (_) {
      emit(WorkoutProgramError('Refresh Failed!'));
    }

    return true;
  }

  void _handleError(Object error) {
    if (error is AppException) {
      emit(WorkoutProgramError(error.message));
      return;
    }

    emit(WorkoutProgramError(error.toString()));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();

    return super.close();
  }
}
