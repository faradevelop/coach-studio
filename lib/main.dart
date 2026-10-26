import 'dart:async';

import 'package:coach_studio/app/coach/app_router.dart';
import 'package:coach_studio/core/bootstrap/font_preloader.dart';
import 'package:coach_studio/core/bootstrap/global_error_handling.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/storage/token_storage.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_theme.dart';
import 'package:coach_studio/core/widgets/responsive/app_scroll_behavior.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_cubit.dart';
import 'package:coach_studio/features/authentication/domain/enums/user_role.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_state.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup global error handling for Flutter errors and platform errors
  setupGlobalErrorHandling();

  // Initialize dependencies and logger
  await initDependencies(
    allowedRole: UserRole.coach,
    navigatorKey: AppRouter.navigatorKey,
  );
  final logger = sl<AppLogger>();

  await verifyFontAssets(logger);

  logger.info('Application starting');
  logger.debug('Initializing dependencies');

  // Initialize token storage
  await sl<TokenStorage>().init();
  logger.debug('Token storage initialized');

  // Kick off session restoration immediately. AppRouter's `redirect` reads
  // AuthCubit's state directly via get_it (independent of the widget
  // tree), so this must run before/alongside `runApp` rather than being
  // deferred to a (potentially lazy) BlocProvider.
  unawaited(sl<AuthCubit>().restoreSession());

  logger.info('Application initialized');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // These Cubits have an app-wide lifecycle, meaning they stay alive at the app level (Singletons provided by get_it)
        // and are shared across tabs and internal pages (Add/Edit/Create).
        BlocProvider(create: (_) => sl<AuthCubit>()),
        BlocProvider(create: (_) => sl<ExerciseCubit>()..loadExercises()),
        BlocProvider(create: (_) => sl<WorkoutProgramCubit>()),
        BlocProvider(create: (_) => sl<AthleteCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.read<WorkoutProgramCubit>().loadPrograms();
            context.read<AthleteCubit>().loadAthletes();

            // The initial loadExercises() above can run before a token
            // exists (fresh login) and end in ExerciseError. Reload only in
            // that case (or if never started), so a restored session that is
            // already loading/loaded doesn't fetch twice.
            final exerciseCubit = context.read<ExerciseCubit>();
            if (exerciseCubit.state is ExerciseInitial ||
                exerciseCubit.state is ExerciseError) {
              exerciseCubit.loadExercises();
            }
          }

          if (state is AuthUnauthenticated) {
            context.read<WorkoutProgramCubit>().reset();
            context.read<AthleteCubit>().reset();
          }
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,

          scrollBehavior: const AppScrollBehavior(),

          locale: const Locale('fa'),
          supportedLocales: const [Locale('fa'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          title: 'Coach Studio',
          theme: AppTheme.light,
          routerConfig: AppRouter.router,
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();
            return MaxWidthBox(
              maxWidth: AppContentWidth.shell,
              expandHeight: true,
              child: child,
            );
          },
        ),
      ),
    );
  }
}
