import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';

abstract class ExerciseRepository {
  Stream<List<Exercise>> watchExercises();

  Future<bool> addExercise(Exercise exercise);

  Future<bool> updateExercise(Exercise exercise);

  Future<bool> deleteExercise(String id);

  Future<Exercise?> getExerciseById(String id);
}
