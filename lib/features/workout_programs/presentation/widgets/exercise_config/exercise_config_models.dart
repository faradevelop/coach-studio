// lib/features/workout_programs/presentation/widgets/exercise_config/exercise_config_models.dart
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';

/// Source-agnostic description of ONE exercise inside the config form.
///
/// Both the Wizard (create) and the Edit page map their own data into this
/// shape, so [ExerciseConfigForm] never knows where the data came from.
class ExerciseConfigItemInput {
  final String exerciseId;
  final String exerciseName;

  /// Raw reps per set. A single element means "same reps for every set".
  final List<String> reps;
  final String tempo;
  final String description;

  const ExerciseConfigItemInput({
    required this.exerciseId,
    required this.exerciseName,
    this.reps = const [],
    this.tempo = '-',
    this.description = '',
  });
}

/// Initial values of the whole form. Read ONCE (in `initState`) so user
/// edits are never reset by an upstream rebuild.
class ExerciseConfigInput {
  /// Raw values; the form parses/clamps them.
  final String sets;
  final String rest;
  final int day;
  final TrainingSystem trainingSystem;

  /// Order is preserved in [ExerciseConfigResult.items].
  final List<ExerciseConfigItemInput> items;

  const ExerciseConfigInput({
    required this.sets,
    required this.rest,
    required this.day,
    required this.trainingSystem,
    required this.items,
  });
}

/// Final values of ONE exercise, as entered by the user.
class ExerciseItemResult {
  final String exerciseId;

  /// Exactly one entry per set.
  final List<String> reps;

  /// Trimmed; never empty (falls back to `-`).
  final String tempo;

  /// Trimmed; may be empty (callers decide whether that means `null`).
  final String description;

  const ExerciseItemResult({
    required this.exerciseId,
    required this.reps,
    required this.tempo,
    required this.description,
  });
}

/// Final values of the whole form.
class ExerciseConfigResult {
  final int sets;
  final int restSeconds;

  /// Same order as [ExerciseConfigInput.items].
  final List<ExerciseItemResult> items;

  const ExerciseConfigResult({
    required this.sets,
    required this.restSeconds,
    required this.items,
  });
}
