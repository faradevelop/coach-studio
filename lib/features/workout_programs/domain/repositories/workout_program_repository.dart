import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';

abstract class WorkoutProgramRepository {
  Stream<List<WorkoutProgram>> watchPrograms();

  Future<WorkoutProgram> addProgram(WorkoutProgram program);

  Future<void> updateProgram(WorkoutProgram program);

  Future<void> deleteProgram(String id);

  Future<void> duplicateProgram(String id, String title);
}
