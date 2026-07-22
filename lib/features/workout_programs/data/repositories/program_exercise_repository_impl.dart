import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:coach_studio/features/workout_programs/data/datasources/program_exercise_firestore_datasource.dart';
import 'package:coach_studio/features/workout_programs/data/models/program_exercise_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/program_exercise_repository.dart';

class ProgramExerciseRepositoryImpl implements ProgramExerciseRepository {
  final ProgramExerciseFirestoreDatasource datasource;
  final ExerciseRepository exerciseRepository;

  ProgramExerciseRepositoryImpl({
    required this.datasource,
    required this.exerciseRepository,
  });

  @override
  Stream<List<ProgramExerciseDetails>> watchProgramExercises(String programId) {
    return datasource.watchProgramExercises(programId).asyncMap((models) async {
      final result = <ProgramExerciseDetails>[];

      for (final model in models) {
        final programExercise = model.toEntity();

        final exercise = await exerciseRepository.getExerciseById(
          programExercise.exerciseId,
        );

        if (exercise != null) {
          result.add(
            ProgramExerciseDetails(
              programExercise: programExercise,
              exercise: exercise,
            ),
          );
        }
      }

      return result;
    });
  }

  @override
  Future<void> addProgramExercise(ProgramExercise exercise) async {
    final nextOrder = await datasource.getNextOrder(
      programId: exercise.programId,
      day: exercise.day,
    );

    final updatedExercise = exercise.copyWith(order: nextOrder);

    await datasource.addProgramExercise(
      ProgramExerciseModel.fromEntity(updatedExercise),
    );
  }

  @override
  Future<void> updateProgramExercise(ProgramExercise exercise) async {
    final oldModel = await datasource.getProgramExerciseById(exercise.id);
    if (oldModel == null) {
      throw Exception('Program exercise not found');
    }

    final oldEntity = oldModel.toEntity();
    var updatedExercise = exercise;

    if (oldEntity.day != exercise.day) {
      final newOrder = await datasource.getNextOrder(
        programId: exercise.programId,
        day: exercise.day,
      );

      updatedExercise = exercise.copyWith(order: newOrder);
    }
    await datasource.updateProgramExercise(
      ProgramExerciseModel.fromEntity(updatedExercise),
    );
  }

  @override
  Future<void> deleteProgramExercise(String id) async {
    await datasource.deleteProgramExercise(id);
  }
}
