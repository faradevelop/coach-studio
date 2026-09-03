// lib/features/workout_programs/presentation/cubit/program_exercise_wizard_cubit.dart
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_item.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'program_exercise_wizard_state.dart';

/// Owns ONLY the in-progress wizard state (which step, what's been
/// entered so far). It never touches GoRouter. Persistence is delegated
/// to [ProgramExerciseCubit] — the single source of truth for the
/// Detail page's exercise list — so a successful submit here shows up
/// there automatically.
class ProgramExerciseWizardCubit extends Cubit<ProgramExerciseWizardState> {
  final String programId;
  final ProgramExerciseCubit programExerciseCubit;
  final AppLogger _logger;

  ProgramExerciseWizardCubit({
    required this.programId,
    required this.programExerciseCubit,
    required AppLogger logger,
  }) : _logger = logger,
       super(const ProgramExerciseWizardState());

  // ── Step 1 ────────────────────────────────────────────────────
  void setDay(int day) => emit(state.copyWith(day: day));

  void setTrainingSystem(TrainingSystem system) {
    final trimmed = state.selectedExercises
        .take(system == TrainingSystem.superSet ? 2 : 1)
        .toList();
    emit(state.copyWith(trainingSystem: system, selectedExercises: trimmed));
  }

  void goToSelectExercises() =>
      emit(state.copyWith(step: WizardStep.selectExercises));

  // ── Step 2 ────────────────────────────────────────────────────
  void toggleExerciseSelection(Exercise exercise) {
    final current = List<Exercise>.from(state.selectedExercises);
    final already = current.any((e) => e.id == exercise.id);

    if (already) {
      current.removeWhere((e) => e.id == exercise.id);
    } else {
      if (current.length >= state.maxSelection) return;
      current.add(exercise);
    }

    emit(state.copyWith(selectedExercises: current));
  }

  bool get canProceedToConfigure =>
      state.selectedExercises.length == state.maxSelection;

  void goToConfigure() {
    if (!canProceedToConfigure) return;

    final configs = <String, ExerciseItemConfig>{};
    for (final exercise in state.selectedExercises) {
      configs[exercise.id] =
          state.itemConfigs[exercise.id] ?? const ExerciseItemConfig();
    }

    emit(state.copyWith(step: WizardStep.configure, itemConfigs: configs));
  }

  // ── Step 3 ────────────────────────────────────────────────────
  void setSets(String sets) => emit(state.copyWith(sets: sets));
  void setRest(String rest) => emit(state.copyWith(rest: rest));

  void updateItemConfig(
    String exerciseId, {
    String? reps,
    String? tempo,
    String? description,
  }) {
    final current = state.itemConfigs[exerciseId] ?? const ExerciseItemConfig();
    final updated = current.copyWith(
      reps: reps,
      tempo: tempo,
      description: description,
    );
    emit(
      state.copyWith(itemConfigs: {...state.itemConfigs, exerciseId: updated}),
    );
  }

  // ── Back handling ─────────────────────────────────────────────
  /// Called from the wizard's PopScope when the user tries to leave via
  /// System/Browser Back or the in-app arrow while not on step 1.
  /// Returns true if a step-back was performed (caller must NOT let the
  /// pop proceed); false when already on step 1 (caller lets it exit).
  bool goToPreviousStep() {
    switch (state.step) {
      case WizardStep.day:
        return false;
      case WizardStep.selectExercises:
        emit(state.copyWith(step: WizardStep.day));
        return true;
      case WizardStep.configure:
        emit(state.copyWith(step: WizardStep.selectExercises));
        return true;
    }
  }

  // ── Submission ───────────────────────────────────────────────
  Future<bool> submit() async {
    emit(state.copyWith(isSubmitting: true, clearError: true));

    final items = state.selectedExercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;
      final config =
          state.itemConfigs[exercise.id] ?? const ExerciseItemConfig();

      return ProgramExerciseItem(
        id: '',
        programExerciseId: '',
        exerciseId: exercise.id,
        order: index + 1,
        reps: config.reps,
        tempo: config.tempo,
        description: config.description.isEmpty ? null : config.description,
      );
    }).toList();

    final programExercise = ProgramExercise(
      id: '',
      workoutId: programId,
      day: state.day,
      order: 0,
      sets: state.sets,
      rest: state.rest,
      trainingSystem: state.trainingSystem,
      items: items,
    );

    final success = await programExerciseCubit.addProgramExercise(
      programExercise,
    );

    if (!success) {
      _logger.warning('ProgramExerciseWizardCubit: submit failed');
      emit(state.copyWith(isSubmitting: false));
      return false;
    }

    emit(state.copyWith(isSubmitting: false));
    return true;
  }
}
