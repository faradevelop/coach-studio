import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';

abstract class ExerciseRepository {
  Stream<List<ExerciseModel>> watchExercises();

  Future<void> addExercise(ExerciseModel exercise);
}
