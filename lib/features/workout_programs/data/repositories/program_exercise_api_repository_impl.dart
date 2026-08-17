import 'package:coach_studio/core/network/api_exception.dart';
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
    try {
      final details = await datasource.getProgramExerciseDetails(workoutId);
      if (details != null) {
        yield details;
      }
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<bool> addProgramExercise(ProgramExercise exercise) async {
    // No client-side "next order" computation here — that logic was
    // Firestore-specific and now lives entirely in the API's
    // ProgramExerciseService (transactional, concurrency-safe).
    try {
      final result = await datasource.createProgramExercise(
        ProgramExerciseModel.fromEntity(exercise),
      );
      return result != null;
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<bool> updateProgramExercise(ProgramExercise exercise) async {
    // Day-change detection and renumbering are likewise handled entirely
    // server-side now; the client just submits the desired new state.
    try {
      final result = await datasource.updateProgramExercise(
        ProgramExerciseModel.fromEntity(exercise),
      );
      return result != null;
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<bool> deleteProgramExercise(String id) {
    try {
      return datasource.deleteProgramExercise(id);
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<bool> reorderProgramExercise(String exerciseId, int targetOrder) {
    try {
      return datasource.reorderProgramExercise(exerciseId, targetOrder);
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }
}
