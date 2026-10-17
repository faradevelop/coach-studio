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
  final String search;
  final List<Muscle> muscles;
  final Equipment? equipment;
  final Difficulty? difficulty;
  final ExerciseType? type;

  const ExerciseFilter({
    this.search = '',
    this.muscles = const [],
    this.equipment,
    this.difficulty,
    this.type,
  });

  bool get isEmpty =>
      search.isEmpty &&
      muscles.isEmpty &&
      equipment == null &&
      difficulty == null &&
      type == null;

  ExerciseFilter copyWith({
    String? search,
    List<Muscle>? muscles,
    Equipment? equipment,
    Difficulty? difficulty,
    ExerciseType? type,
    bool clearEquipment = false,
    bool clearDifficulty = false,
    bool clearType = false,
  }) => ExerciseFilter(
    search: search ?? this.search,
    muscles: muscles ?? this.muscles,
    equipment: clearEquipment ? null : (equipment ?? this.equipment),
    difficulty: clearDifficulty ? null : (difficulty ?? this.difficulty),
    type: clearType ? null : (type ?? this.type),
  );
}
