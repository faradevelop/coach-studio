import 'dart:async';

import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/program_exercise_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'program_exercise_state.dart';

class ProgramExerciseCubit extends Cubit<ProgramExerciseState> {
  final ProgramExerciseRepository repository;

  StreamSubscription? _subscription;
  String? _workoutId;

  ProgramExerciseCubit({required this.repository})
    : super(const ProgramExerciseInitial());

  void loadExercises(String workoutId) {
    _workoutId = workoutId;

    emit(const ProgramExerciseLoading());

    _subscription?.cancel();

    _subscription = repository.watchProgramExercises(workoutId).listen((
      exercises,
    ) {
      emit(ProgramExerciseLoaded(exercises: exercises));
    }, onError: _handleError);
  }

  Future<void> _refreshExercises() async {
    final workoutId = _workoutId;

    if (workoutId == null) return;

    final exercises = await repository.watchProgramExercises(workoutId).first;

    emit(ProgramExerciseLoaded(exercises: exercises, isSubmitting: false));
  }

  Future<bool> addProgramExercise(ProgramExercise exercise) async {
    final current = state;

    if (current is! ProgramExerciseLoaded) {
      return false;
    }

    emit(current.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.addProgramExercise(exercise);

      if (!success) {
        _restoreState(current);
        return false;
      }
    } on AppException catch (e) {
      emit(ProgramExerciseError(e.message));
      return false;
    } catch (e) {
      emit(ProgramExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
    } on AppException catch (e) {
      emit(ProgramExerciseError(e.message));
    } catch (e) {
      emit(ProgramExerciseError('Refresh failed!'));
    }

    return true;
  }

  Future<bool> updateProgramExercise(ProgramExercise exercise) async {
    final current = state;

    if (current is! ProgramExerciseLoaded) {
      return false;
    }

    emit(current.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.updateProgramExercise(exercise);

      if (!success) {
        _restoreState(current);
        return false;
      }
    } on AppException catch (e) {
      emit(ProgramExerciseError(e.message));
      return false;
    } catch (e) {
      emit(ProgramExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
    } on AppException catch (e) {
      emit(ProgramExerciseError(e.message));
    } catch (e) {
      emit(ProgramExerciseError('Refresh failed!'));
    }

    return true;
  }

  Future<bool> deleteExercise(String id) async {
    final current = state;

    if (current is! ProgramExerciseLoaded) {
      return false;
    }

    emit(current.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.deleteProgramExercise(id);

      if (!success) {
        _restoreState(current);
        return false;
      }
    } on AppException catch (e) {
      emit(ProgramExerciseError(e.message));
      return false;
    } catch (e) {
      emit(ProgramExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
    } on AppException catch (e) {
      emit(ProgramExerciseError(e.message));
    } catch (e) {
      emit(ProgramExerciseError('Refresh failed!'));
    }

    return true;
  }

  Future<bool> reorderProgramExercise(
    String exerciseId,
    int targetOrder,
  ) async {
    final current = state;

    if (current is! ProgramExerciseLoaded || current.isSubmitting) {
      return false;
    }

    emit(current.copyWith(isSubmitting: true));

    // Mutation
    try {
      final success = await repository.reorderProgramExercise(
        exerciseId,
        targetOrder,
      );

      if (!success) {
        _restoreState(current);
        return false;
      }
    } on AppException catch (e) {
      emit(ProgramExerciseError(e.message));
      return false;
    } catch (e) {
      emit(ProgramExerciseError(e.toString()));
      return false;
    }

    // Refresh
    try {
      await _refreshExercises();
    } on AppException catch (e) {
      emit(ProgramExerciseError(e.message));
    } catch (e) {
      emit(ProgramExerciseError('Refresh failed!'));
    }

    return true;
  }

  void _restoreState(ProgramExerciseLoaded previousState) {
    emit(previousState.copyWith(isSubmitting: false));
  }

  void _handleError(Object error) {
    if (error is AppException) {
      emit(ProgramExerciseError(error.message));
      return;
    }

    emit(ProgramExerciseError(error.toString()));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
