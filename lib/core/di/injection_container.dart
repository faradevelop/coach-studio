import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_studio/features/exercises/data/datasources/exercise_firestore_datasource.dart';
import 'package:coach_studio/features/exercises/data/repositories/exercise_repository_impl.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/data/datasources/program_exercise_firestore_datasource.dart';
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

  sl.registerLazySingleton(
    () => ProgramExerciseFirestoreDatasource(firestore: sl()),
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

  // Bloc / Cubit
  //
  // ExerciseCubit and WorkoutProgramCubit are intentionally registered as Singletons:
  // These two Cubits are provided above the MaterialApp (outside of GoRouter)
  // so that both the list screens (inside Tabs) and internal pages such as Add/Edit,
  // which are pushed on the root Navigator, can access the same instance.
  // This prevents the list state from being lost when navigating to Add/Edit
  // and returning back.
  sl.registerLazySingleton(() => ExerciseCubit(repository: sl()));
  sl.registerLazySingleton(() => WorkoutProgramCubit(repository: sl()));

  // ProgramExerciseCubit remains a Factory:
  // A new instance is created every time we enter the Program Detail flow,
  // and it is disposed when leaving that flow (as required).
  // Persisting its state across tabs is not needed.
  sl.registerFactory(() => ProgramExerciseCubit(repository: sl()));
}
