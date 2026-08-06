import 'package:coach_studio/features/workout_programs/data/datasources/program_exercise_api_datasource.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/program_exercise_repository.dart';

class ProgramExerciseApiRepositoryImpl implements ProgramExerciseRepository {
  final ProgramExerciseApiDatasource datasource;

  ProgramExerciseApiRepositoryImpl({required this.datasource});

  @override
  Stream<List<ProgramExerciseDetails>> watchProgramExercises(
    String workoutId,
  ) async* {
    final details = await datasource.getProgramExerciseDetails(workoutId);
    yield details;
  }

  @override
  Future<void> addProgramExercise(ProgramExercise exercise) {
    // No client-side "next order" computation here — that logic was
    // Firestore-specific and now lives entirely in the API's
    // ProgramExerciseService (transactional, concurrency-safe).
    return datasource.createProgramExercise(
      ProgramExerciseModel.fromEntity(exercise),
    );
  }

  @override
  Future<void> updateProgramExercise(ProgramExercise exercise) {
    // Day-change detection and renumbering are likewise handled entirely
    // server-side now; the client just submits the desired new state.
    return datasource.updateProgramExercise(
      ProgramExerciseModel.fromEntity(exercise),
    );
  }

  @override
  Future<void> deleteProgramExercise(String id) {
    return datasource.deleteProgramExercise(id);
  }
}
