import 'package:coach_studio/core/constants/api_config.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/logger/app_logger_impl.dart';
import 'package:coach_studio/core/network/api_client.dart';
import 'package:coach_studio/core/notifications/data/floating_snackbar_notification.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/storage/token_storage.dart';
import 'package:coach_studio/features/athlete/data/datasources/athlete_api_datasource.dart';
import 'package:coach_studio/features/athlete/data/repositories/athlete_api_repository_impl.dart';
import 'package:coach_studio/features/athlete/domain/repositories/athlete_repository.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_cubit.dart';
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
import 'package:coach_studio/features/authentication/domain/enums/user_role.dart';
import 'package:coach_studio/features/coaches/data/datasources/coach_api_datasource.dart';
import 'package:coach_studio/features/coaches/data/repositories/coach_api_repository_impl.dart';
import 'package:coach_studio/features/coaches/domain/repositories/coach_repository.dart';
import 'package:coach_studio/features/coaches/presentation/cubit/coach_cubit.dart';
import 'package:flutter/widgets.dart' show GlobalKey, NavigatorState;
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> initDependencies({
  required UserRole allowedRole,
  required GlobalKey<NavigatorState> navigatorKey,
}) async {
  // External / Core

  // Logger must be registered first — used by other dependencies
  sl.registerLazySingleton<AppLogger>(() => AppLoggerImpl());

  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());

  sl.registerLazySingleton<ApiClient>(
    () =>
        ApiClient(baseUrl: ApiConfig.baseUrl, tokenStorage: sl(), logger: sl()),
  );

  // Notification

  sl.registerLazySingleton<AppNotification>(
    () => FloatingSnackbarNotification(navigatorKey: navigatorKey),
  );

  // Data sources

  sl.registerLazySingleton<AuthApiDatasource>(
    () => AuthApiDatasource(client: sl(), logger: sl()),
  );

  sl.registerLazySingleton<ExerciseApiDatasource>(
    () => ExerciseApiDatasource(client: sl(), logger: sl()),
  );

  sl.registerLazySingleton<WorkoutProgramApiDatasource>(
    () => WorkoutProgramApiDatasource(client: sl(), logger: sl()),
  );

  sl.registerLazySingleton<ProgramExerciseApiDatasource>(
    () => ProgramExerciseApiDatasource(client: sl(), logger: sl()),
  );

  sl.registerLazySingleton<CoachApiDatasource>(
    () => CoachApiDatasource(client: sl(), logger: sl()),
  );

  sl.registerLazySingleton<AthleteApiDatasource>(
    () => AthleteApiDatasource(client: sl(), logger: sl()),
  );

  // Repository

  sl.registerLazySingleton<AuthRepository>(
    () => AuthApiRepositoryImpl(datasource: sl(), logger: sl()),
  );

  sl.registerLazySingleton<ExerciseRepository>(
    () => ExerciseApiRepositoryImpl(datasource: sl(), logger: sl()),
  );

  sl.registerLazySingleton<WorkoutProgramRepository>(
    () => WorkoutProgramApiRepositoryImpl(datasource: sl(), logger: sl()),
  );

  sl.registerLazySingleton<ProgramExerciseRepository>(
    () => ProgramExerciseApiRepositoryImpl(datasource: sl(), logger: sl()),
  );

  sl.registerLazySingleton<CoachRepository>(
    () => CoachApiRepositoryImpl(datasource: sl(), logger: sl()),
  );

  sl.registerLazySingleton<AthleteRepository>(
    () => AthleteApiRepositoryImpl(datasource: sl(), logger: sl()),
  );

  // Bloc / Cubit
  //
  sl.registerLazySingleton(
    () => AuthCubit(
      repository: sl(),
      tokenStorage: sl(),
      logger: sl(),
      allowedRole: allowedRole,
    ),
  );

  sl.registerLazySingleton(() => ExerciseCubit(repository: sl(), logger: sl()));

  sl.registerLazySingleton(
    () => WorkoutProgramCubit(repository: sl(), logger: sl()),
  );

  sl.registerLazySingleton(() => AthleteCubit(repository: sl(), logger: sl()));

  // ProgramExerciseCubit remains a Factory: a new instance per Program Detail
  // flow, disposed on exit — no cross-tab persistence required.
  sl.registerFactory(
    () => ProgramExerciseCubit(repository: sl(), logger: sl()),
  );

  sl.registerLazySingleton(() => CoachCubit(repository: sl(), logger: sl()));

  // Wire the network layer to the auth layer: any 401 response forces the
  // app back to the unauthenticated state (see ApiClient.onUnauthorized
  // and AuthCubit.handleUnauthorized).
  sl<ApiClient>().onUnauthorized = () => sl<AuthCubit>().handleUnauthorized();
}
