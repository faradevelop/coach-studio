import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';

abstract class WorkoutProgramRepository {
  Stream<List<WorkoutProgram>> watchPrograms();

  Future<void> addProgram(WorkoutProgram program);

  Future<void> updateProgram(WorkoutProgram program);

  Future<void> deleteProgram(String id);
}
