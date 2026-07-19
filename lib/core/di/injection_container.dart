import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_studio/features/exercises/data/datasources/exercise_firestore_datasource.dart';
import 'package:coach_studio/features/exercises/data/repositories/exercise_repository_impl.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External

  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data sources

  sl.registerLazySingleton<ExerciseFirestoreDatasource>(
    () => ExerciseFirestoreDatasource(firestore: sl()),
  );

  // Repository

  sl.registerLazySingleton<ExerciseRepository>(
    () => ExerciseRepositoryImpl(datasource: sl()),
  );
}
