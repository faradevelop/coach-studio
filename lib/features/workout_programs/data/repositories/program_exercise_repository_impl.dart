import 'package:coach_studio/features/workout_programs/data/datasources/program_exercise_firestore_datasource.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/program_exercise_repository.dart';

class ProgramExerciseRepositoryImpl implements ProgramExerciseRepository {
  final ProgramExerciseFirestoreDatasource datasource;

  ProgramExerciseRepositoryImpl({required this.datasource});

  @override
  Stream<List<ProgramExercise>> watchProgramExercises(String programId) {
    return datasource
        .watchProgramExercises(programId)
        .map((models) => models.map((e) => e.toEntity()).toList());
  }

  @override
  Future<void> addProgramExercise(ProgramExercise exercise) async {
    await datasource.addProgramExercise(
      ProgramExerciseModel.fromEntity(exercise),
    );
  }

  @override
  Future<void> updateProgramExercise(ProgramExercise exercise) async {
    await datasource.updateProgramExercise(
      ProgramExerciseModel.fromEntity(exercise),
    );
  }

  @override
  Future<void> deleteProgramExercise(String id) async {
    await datasource.deleteProgramExercise(id);
  }
}
