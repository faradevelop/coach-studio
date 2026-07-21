import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';

abstract class ExerciseRepository {
  Stream<List<Exercise>> watchExercises();

  Future<void> addExercise(Exercise exercise);

  Future<void> updateExercise(Exercise exercise);

  Future<void> deleteExercise(String id);

  Future<Exercise?> getExerciseById(String id);
}
