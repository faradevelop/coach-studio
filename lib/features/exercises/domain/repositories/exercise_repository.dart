import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';

abstract class ExerciseRepository {
  Future<List<ExerciseModel>> getExercises();

  Future<void> addExercise(ExerciseModel exercise);
}
