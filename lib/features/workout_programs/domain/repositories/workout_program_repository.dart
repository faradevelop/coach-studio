import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';

abstract class WorkoutProgramRepository {
  Stream<List<WorkoutProgram>> watchPrograms();

  Future<WorkoutProgram?> addProgram(WorkoutProgram program);

  Future<bool> updateProgram(WorkoutProgram program);

  Future<bool> deleteProgram(String id);

  Future<bool> duplicateProgram(String id, String title);
}
