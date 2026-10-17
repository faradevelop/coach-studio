import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';

abstract class ProgramExerciseRepository {
  Stream<List<ProgramExerciseDetails>> watchProgramExercises(String workoutId);

  Future<bool> addProgramExercise(ProgramExercise exercise);

  Future<bool> updateProgramExercise(ProgramExercise exercise);

  Future<bool> deleteProgramExercise(String id);

  Future<bool> reorderProgramExercise(String exerciseId, int targetOrder);
}
