import 'package:coach_studio/app/routing/app_router.dart';
import 'package:coach_studio/core/constants/api_config.dart';
import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/core/notifications/data/floating_snackbar_notification.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/storage/token_storage.dart';
import 'package:coach_studio/features/authentication/data/datasources/auth_api_datasource.dart';
import 'package:coach_studio/features/authentication/data/repositories/auth_api_repository_impl.dart';
import 'package:coach_studio/features/authentication/domain/repositories/auth_repository.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/exercises/data/datasources/exercise_api_datasource.dart';
import 'package:coach_studio/features/exercises/data/repositories/exercise_api_repository_impl.dart';
import 'package:coach_studio/features/exercises/domain/repositories/exercise_repository.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/data/datasources/program_exercise_api_datasource.dart';
import 'package:coach_studio/features/workout_programs/data/datasources/workout_program_api_datasource.dart';
import 'package:coach_studio/features/workout_programs/data/repositories/program_exercise_api_repository_impl.dart';
import 'package:coach_studio/features/workout_programs/data/repositories/workout_program_api_repository_impl.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/program_exercise_repository.dart';
import 'package:coach_studio/features/workout_programs/domain/repositories/workout_program_repository.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External / Core

  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(baseUrl: ApiConfig.baseUrl, tokenStorage: sl()),
  );

  // Notification

  sl.registerLazySingleton<AppNotification>(
    () => FloatingSnackbarNotification(navigatorKey: AppRouter.navigatorKey),
  );

  // Data sources

  sl.registerLazySingleton<AuthApiDatasource>(
    () => AuthApiDatasource(client: sl()),
  );

  sl.registerLazySingleton<ExerciseApiDatasource>(
    () => ExerciseApiDatasource(client: sl()),
  );

  sl.registerLazySingleton<WorkoutProgramApiDatasource>(
    () => WorkoutProgramApiDatasource(client: sl()),
  );

  sl.registerLazySingleton<ProgramExerciseApiDatasource>(
    () => ProgramExerciseApiDatasource(client: sl()),
  );

  // Repository

  sl.registerLazySingleton<AuthRepository>(
    () => AuthApiRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<ExerciseRepository>(
    () => ExerciseApiRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<WorkoutProgramRepository>(
    () => WorkoutProgramApiRepositoryImpl(datasource: sl()),
  );

  sl.registerLazySingleton<ProgramExerciseRepository>(
    () => ProgramExerciseApiRepositoryImpl(datasource: sl()),
  );

  // Bloc / Cubit
  //
  // AuthCubit, ExerciseCubit and WorkoutProgramCubit are intentionally
  // registered as Singletons: provided above the MaterialApp (outside of
  // GoRouter) so both the list screens and internal pages (Add/Edit) share
  // the same instance across navigation, and so AppRouter's `redirect` can
  // read AuthCubit's state directly via `sl<AuthCubit>()`.
  sl.registerLazySingleton(
    () => AuthCubit(repository: sl(), tokenStorage: sl()),
  );
  sl.registerLazySingleton(() => ExerciseCubit(repository: sl()));
  sl.registerLazySingleton(() => WorkoutProgramCubit(repository: sl()));

  // ProgramExerciseCubit remains a Factory: a new instance per Program Detail
  // flow, disposed on exit — no cross-tab persistence required.
  sl.registerFactory(() => ProgramExerciseCubit(repository: sl()));

  // Wire the network layer to the auth layer: any 401 response forces the
  // app back to the unauthenticated state (see ApiClient.onUnauthorized
  // and AuthCubit.handleUnauthorized).
  sl<ApiClient>().onUnauthorized = () => sl<AuthCubit>().handleUnauthorized();
}
