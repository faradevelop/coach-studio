import 'dart:async';
import 'dart:ui';

import 'package:coach_studio/app/routing/app_router.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/storage/token_storage.dart';
import 'package:coach_studio/core/theme/app_theme.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup global error handling for Flutter errors and platform errors
  _setupGlobalErrorHandling();

  // Initialize dependencies and logger
  await initDependencies();
  final logger = sl<AppLogger>();

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

/// Setup global error handling for Flutter and async errors.
void _setupGlobalErrorHandling() {
  // Capture Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    final logger = sl<AppLogger>();
    logger.error(
      'Flutter Error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Capture unhandled async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    final logger = sl<AppLogger>();
    logger.error('Platform Error', error: error, stackTrace: stack);
    return true;
  };
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
        BlocProvider(create: (_) => sl<WorkoutProgramCubit>()..loadPrograms()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,

        locale: const Locale('fa'),
        supportedLocales: const [Locale('fa')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        title: 'Coach Studio',
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1000;

              return Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: isDesktop ? 1000 : double.infinity,
                  height: double.infinity,
                  child: child,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
