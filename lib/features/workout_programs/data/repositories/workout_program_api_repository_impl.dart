import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/workout_programs/data/datasources/workout_program_api_datasource.dart';
import 'package:coach_studio/features/workout_programs/data/models/workout_program_model.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';

class WorkoutProgramApiRepositoryImpl implements WorkoutProgramRepository {
  final WorkoutProgramApiDatasource datasource;

  WorkoutProgramApiRepositoryImpl({required this.datasource});

  @override
  Stream<List<WorkoutProgram>> watchPrograms() async* {
    try {
      final models = await datasource.getPrograms();
      if (models != null) {
        yield models.map((m) => m.toEntity()).toList();
      }
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<WorkoutProgram?> addProgram(WorkoutProgram program) async {
    try {
      final created = await datasource.createProgram(
        WorkoutProgramModel.fromEntity(program),
      );
      if (created != null) {
        return created.toEntity();
      }
      return null;
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<bool> updateProgram(WorkoutProgram program) {
    try {
      return datasource.updateProgram(WorkoutProgramModel.fromEntity(program));
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<bool> deleteProgram(String id) {
    try {
      return datasource.deleteProgram(id);
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }

  @override
  Future<bool> duplicateProgram(String id, String title) {
    try {
      return datasource.duplicateProgram(id, title);
    } on ApiException catch (e) {
      throw ApiException.mapApiException(e);
    }
  }
}
