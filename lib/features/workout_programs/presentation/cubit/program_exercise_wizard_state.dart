// lib/features/workout_programs/presentation/cubit/program_exercise_wizard_state.dart
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';

/// The wizard's 3 steps live ONLY here — never as separate GoRoutes.
enum WizardStep { day, selectExercises, configure }

class ExerciseItemConfig {
  final String reps;
  final String tempo;
  final String description;

  const ExerciseItemConfig({
    this.reps = '',
    this.tempo = '',
    this.description = '',
  });

  ExerciseItemConfig copyWith({
    String? reps,
    String? tempo,
    String? description,
  }) {
    return ExerciseItemConfig(
      reps: reps ?? this.reps,
      tempo: tempo ?? this.tempo,
      description: description ?? this.description,
    );
  }
}

class ProgramExerciseWizardState {
  final WizardStep step;
  final int day;
  final TrainingSystem trainingSystem;
  final List<Exercise> selectedExercises;
  final Map<String, ExerciseItemConfig> itemConfigs; // keyed by exerciseId
  final String sets;
  final String rest;
  final bool isSubmitting;
  final String? errorMessage;

  const ProgramExerciseWizardState({
    this.step = WizardStep.day,
    this.day = 1,
    this.trainingSystem = TrainingSystem.normal,
    this.selectedExercises = const [],
    this.itemConfigs = const {},
    this.sets = '3',
    this.rest = '30',
    this.isSubmitting = false,
    this.errorMessage,
  });

  int get maxSelection => trainingSystem == TrainingSystem.superSet ? 2 : 1;

  ProgramExerciseWizardState copyWith({
    WizardStep? step,
    int? day,
    TrainingSystem? trainingSystem,
    List<Exercise>? selectedExercises,
    Map<String, ExerciseItemConfig>? itemConfigs,
    String? sets,
    String? rest,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProgramExerciseWizardState(
      step: step ?? this.step,
      day: day ?? this.day,
      trainingSystem: trainingSystem ?? this.trainingSystem,
      selectedExercises: selectedExercises ?? this.selectedExercises,
      itemConfigs: itemConfigs ?? this.itemConfigs,
      sets: sets ?? this.sets,
      rest: rest ?? this.rest,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
