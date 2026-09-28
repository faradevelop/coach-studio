import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';
import 'package:coach_studio/features/exercises/domain/enums/difficulty.dart';
import 'package:coach_studio/features/exercises/domain/enums/equipment.dart';
import 'package:coach_studio/features/exercises/domain/enums/exercise_type.dart';

/// Value object describing the currently applied exercise filters.
/// Lives in the domain layer because [matches] encodes the actual filtering
/// rule against the [Exercise] entity, independent of any UI.
///
/// Muscle and equipment are multi-select (an exercise can target several
/// muscles, and a user may want to browse across a few equipment types at
/// once); difficulty and type are single-select, mirroring the fact that
/// each [Exercise] carries exactly one value for each.
class ExerciseFilter {
  final List<Muscle> muscles;
  final List<Equipment> equipment;
  final Difficulty? difficulty;
  final ExerciseType? type;

  const ExerciseFilter({
    this.muscles = const [],
    this.equipment = const [],
    this.difficulty,
    this.type,
  });

  bool get isEmpty =>
      muscles.isEmpty &&
      equipment.isEmpty &&
      difficulty == null &&
      type == null;

  ExerciseFilter copyWith({
    List<Muscle>? muscles,
    List<Equipment>? equipment,
    Difficulty? difficulty,
    ExerciseType? type,
    bool clearDifficulty = false,
    bool clearType = false,
  }) {
    return ExerciseFilter(
      muscles: muscles ?? this.muscles,
      equipment: equipment ?? this.equipment,
      difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
      type: clearType ? null : (type ?? this.type),
    );
  }

  /// True when [exercise] satisfies every currently active criterion.
  bool matches(Exercise exercise) {
    if (muscles.isNotEmpty &&
        !muscles.any(
          (m) => exercise.targetMuscles.any((em) => em.id == m.id),
        )) {
      return false;
    }

    if (equipment.isNotEmpty && !equipment.contains(exercise.equipment)) {
      return false;
    }

    if (difficulty != null && exercise.difficulty != difficulty) {
      return false;
    }

    if (type != null && exercise.type != type) {
      return false;
    }

    return true;
  }
}
