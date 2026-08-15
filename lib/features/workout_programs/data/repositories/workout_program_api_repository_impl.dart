import 'package:coach_studio/features/workout_programs/data/datasources/workout_program_api_datasource.dart';
import 'package:coach_studio/features/workout_programs/data/models/workout_program_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';

class WorkoutProgramApiRepositoryImpl implements WorkoutProgramRepository {
  final WorkoutProgramApiDatasource datasource;

  WorkoutProgramApiRepositoryImpl({required this.datasource});

  @override
  Stream<List<WorkoutProgram>> watchPrograms() async* {
    final models = await datasource.getPrograms();
    yield models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<WorkoutProgram> addProgram(WorkoutProgram program) async {
    final created = await datasource.createProgram(
      WorkoutProgramModel.fromEntity(program),
    );
    return created.toEntity();
  }

  @override
  Future<void> updateProgram(WorkoutProgram program) {
    return datasource.updateProgram(WorkoutProgramModel.fromEntity(program));
  }

  @override
  Future<void> deleteProgram(String id) {
    return datasource.deleteProgram(id);
  }

  @override
  Future<void> duplicateProgram(String id, String title) {
    return datasource.duplicateProgram(id, title);
  }
}
