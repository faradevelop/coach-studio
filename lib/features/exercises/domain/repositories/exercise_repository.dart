import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';

abstract class ExerciseRepository {
  Stream<List<Exercise>> watchExercises();

  /// Searches/filters exercises server-side. All parameters are optional —
  /// only the ones with a value are sent to the API. [muscleSlugs] (when
  /// provided) is sent as a single comma-separated `muscles` parameter.
  Future<List<Exercise>?> searchExercises({
    String? search,
    String? type,
    String? difficulty,
    String? equipment,
    List<String>? muscleSlugs,
  });

  Future<bool> addExercise(Exercise exercise);

  Future<bool> updateExercise(Exercise exercise);

  Future<bool> deleteExercise(String id);

  Future<Exercise?> getExerciseById(String id);

  Future<List<Muscle>> getMuscles();
}
