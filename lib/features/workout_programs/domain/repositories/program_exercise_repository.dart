import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';

abstract class ProgramExerciseRepository {
  Stream<List<ProgramExercise>> watchProgramExercises(String programId);

  Future<void> addProgramExercise(ProgramExercise exercise);

  Future<void> updateProgramExercise(ProgramExercise exercise);

  Future<void> deleteProgramExercise(String id);
}
