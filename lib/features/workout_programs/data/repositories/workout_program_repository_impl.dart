import 'package:coach_studio/features/workout_programs/data/datasources/workout_program_firestore_datasource.dart';
import 'package:coach_studio/features/workout_programs/data/models/workout_program_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';

class WorkoutProgramRepositoryImpl implements WorkoutProgramRepository {
  final WorkoutProgramFirestoreDatasource datasource;

  WorkoutProgramRepositoryImpl({required this.datasource});

  @override
  Stream<List<WorkoutProgram>> watchPrograms() {
    return datasource.watchPrograms().map(
      (programs) => programs.map((program) => program.toEntity()).toList(),
    );
  }

  @override
  Future<WorkoutProgram> addProgram(WorkoutProgram program) async {
    final model = WorkoutProgramModel(
      id: program.id,
      title: program.title,
      goal: program.goal,
      level: program.level,
      daysPerWeek: program.daysPerWeek,
      notes: program.notes,
      isTemplate: program.isTemplate,
    );

    final workoutProgramModel = await datasource.addProgram(model);

    return workoutProgramModel.toEntity();
  }

  @override
  Future<void> updateProgram(WorkoutProgram program) async {
    await datasource.updateProgram(
      WorkoutProgramModel(
        id: program.id,
        title: program.title,
        goal: program.goal,
        level: program.level,
        daysPerWeek: program.daysPerWeek,
        notes: program.notes,
        isTemplate: program.isTemplate,
      ),
    );
  }

  @override
  Future<void> deleteProgram(String id) async {
    await datasource.deleteProgram(id);
  }
}
