import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';

/// Every method either completes or throws an [AppException].
abstract class ProgramExerciseRepository {
  Future<List<ProgramExerciseDetails>> getProgramExercises(String workoutId);

  Future<void> addProgramExercise(ProgramExercise exercise);

  Future<void> updateProgramExercise(ProgramExercise exercise);

  Future<void> deleteProgramExercise(String id);

  Future<void> reorderProgramExercise(String exerciseId, int targetOrder);
}
