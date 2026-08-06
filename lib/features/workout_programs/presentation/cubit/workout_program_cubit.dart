import 'dart:async';

import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutProgramCubit extends Cubit<WorkoutProgramState> {
  final WorkoutProgramRepository repository;

  StreamSubscription? _subscription;

  WorkoutProgramCubit({required this.repository})
    : super(WorkoutProgramInitial());

  void loadPrograms() {
    emit(WorkoutProgramLoading());

    _subscription?.cancel();

    _subscription = repository.watchPrograms().listen(
      (programs) {
        emit(WorkoutProgramLoaded(programs));
      },

      onError: (error) {
        emit(WorkoutProgramError(error.toString()));
      },
    );
  }

  Future<void> _refreshPrograms() async {
    final programs = await repository.watchPrograms().first;

    emit(WorkoutProgramLoaded(programs));
  }

  Future<WorkoutProgram?> addProgram(WorkoutProgram program) async {
    try {
      final createdProgram = await repository.addProgram(program);
      await _refreshPrograms();
      return createdProgram;
    } catch (e) {
      emit(WorkoutProgramError(e.toString()));
      return null;
    }
  }

  Future<void> updateProgram(WorkoutProgram program) async {
    try {
      await repository.updateProgram(program);
      await _refreshPrograms();
    } catch (e) {
      emit(WorkoutProgramError(e.toString()));
    }
  }

  Future<void> deleteProgram(String id) async {
    try {
      await repository.deleteProgram(id);
      await _refreshPrograms();
    } catch (e) {
      emit(WorkoutProgramError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();

    return super.close();
  }
}
