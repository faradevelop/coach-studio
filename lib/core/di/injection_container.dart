import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_studio/features/exercises/data/datasources/exercise_firestore_datasource.dart';
import 'package:coach_studio/features/exercises/data/repositories/exercise_repository_impl.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/data/datasources/workout_program_firestore_datasource.dart';
import 'package:coach_studio/features/workout_programs/data/repositories/program_exercise_repository_impl.dart';
import 'package:coach_studio/features/workout_programs/data/repositories/workout_program_repository_impl.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/program_exercise_repository.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External

  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data sources

  sl.registerLazySingleton<ExerciseFirestoreDatasource>(
    () => ExerciseFirestoreDatasource(firestore: sl()),
  );

  sl.registerLazySingleton(
    () => WorkoutProgramFirestoreDatasource(firestore: sl()),
  );

  // Repository

  sl.registerLazySingleton<ExerciseRepository>(
    () => ExerciseRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<WorkoutProgramRepository>(
    () => WorkoutProgramRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<ProgramExerciseRepository>(
    () => ProgramExerciseRepositoryImpl(
      datasource: sl(),
      exerciseRepository: sl(),
    ),
  );

  //Bloc

  sl.registerFactory(() => ExerciseCubit(repository: sl()));

  sl.registerFactory(() => WorkoutProgramCubit(repository: sl()));

  sl.registerFactory(() => ProgramExerciseCubit(repository: sl()));
}
