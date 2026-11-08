import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';

/// Every method either completes or throws an [AppException].
abstract class ExerciseRepository {
  /// Server-side search/filter. All parameters are optional; [muscleSlugs]
  /// is sent as a single comma-separated `muscles` parameter.
  Future<List<Exercise>> searchExercises({
    String? search,
    String? type,
    String? difficulty,
    String? equipment,
    List<String>? muscleSlugs,
  });

  Future<void> addExercise(Exercise exercise);

  Future<void> updateExercise(Exercise exercise);

  Future<void> deleteExercise(String id);

  Future<Exercise?> getExerciseById(String id);

  Future<List<Muscle>> getMuscles();
}
