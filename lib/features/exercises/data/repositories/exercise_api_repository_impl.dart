import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/features/exercises/data/datasources/exercise_api_datasource.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';

class ExerciseApiRepositoryImpl implements ExerciseRepository {
  final ExerciseApiDatasource datasource;

  ExerciseApiRepositoryImpl({required this.datasource});

  @override
  Stream<List<Exercise>> watchExercises() async* {
    // Single-emission stream: fulfills the existing Stream<...> contract
    // without simulating real-time push updates. See Section 6 note.
    try {
      final models = await datasource.getExercises();
      if (models != null) {
        yield models.map((model) => model.toEntity()).toList();
      }
    } on ApiException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<bool> addExercise(Exercise exercise) async {
    try {
      final result = await datasource.createExercise(
        ExerciseModel.fromEntity(exercise),
      );
      return result != null;
    } on ApiException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<bool> updateExercise(Exercise exercise) async {
    try {
      return await datasource.updateExercise(
        ExerciseModel.fromEntity(exercise),
      );
    } on ApiException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<bool> deleteExercise(String id) async {
    try {
      return await datasource.deleteExercise(id);
    } on ApiException catch (e) {
      throw _mapApiException(e);
    }
  }

  @override
  Future<Exercise?> getExerciseById(String id) async {
    try {
      final model = await datasource.getExerciseById(id);
      return model?.toEntity();
    } on ApiException catch (e) {
      throw _mapApiException(e);
    }
  }

  AppException _mapApiException(ApiException exception) {
    switch (exception.statusCode) {
      case 404:
        return NotFoundException(exception.message);
      case 422:
        return ValidationException(exception.message);
      case 500:
        return ServerException(exception.message);
      default:
        return ServerException(exception.message);
    }
  }
}
