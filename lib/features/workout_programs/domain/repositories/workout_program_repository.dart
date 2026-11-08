import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_filter.dart';

/// Every method either completes or throws an [AppException].
abstract class WorkoutProgramRepository {
  Future<List<WorkoutProgram>> getPrograms({
    WorkoutProgramFilter filter = const WorkoutProgramFilter(),
  });

  Future<WorkoutProgram> addProgram(WorkoutProgram program);

  Future<void> updateProgram(WorkoutProgram program);

  Future<void> deleteProgram(String id);

  Future<void> duplicateProgram(String id, String title);

  Future<WorkoutProgram> addDay(String programId);

  Future<void> deleteDay(String programId, int day);

  Future<void> reorderDay(String programId, int day, int targetOrder);
}
