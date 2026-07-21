import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';

abstract class ProgramExerciseRepository {
  Stream<List<ProgramExerciseDetails>> watchProgramExercises(String programId);

  Future<void> addProgramExercise(ProgramExercise exercise);

  Future<void> updateProgramExercise(ProgramExercise exercise);

  Future<void> deleteProgramExercise(String id);
}
