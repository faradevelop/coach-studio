import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/app_routes.dart';
import 'package:coach_studio/app/routing/go_router_refresh_stream.dart';
import 'package:coach_studio/app/routing/scaffold_with_bottom_nav.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/app_error_state.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_state.dart';
import 'package:coach_studio/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:coach_studio/features/authentication/presentation/pages/login_page.dart';
import 'package:coach_studio/features/authentication/presentation/pages/reset_password_page.dart';
import 'package:coach_studio/features/authentication/presentation/pages/settings_page.dart';
import 'package:coach_studio/features/authentication/presentation/pages/splash_page.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/presentation/pages/add_exercise_page.dart';
import 'package:coach_studio/features/exercises/presentation/pages/edit_exercise_page.dart';
import 'package:coach_studio/features/exercises/presentation/pages/exercise_list_page.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/create_workout_program_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/exercise_configuration_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/program_exercise_wizard_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_detail_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _exerciseBranchNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'exerciseBranch');
  static final GlobalKey<NavigatorState> _programBranchNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'programBranch');
  static final GlobalKey<NavigatorState> _settingsBranchNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'settingsBranch');

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(sl<AuthCubit>().stream),

    // Defense in depth ONLY (see RCA). Every route below is designed to
    // rebuild its required state from the URL + data layer alone, so
    // this should rarely fire — but if something we haven't anticipated
    // still slips through, this keeps it a recoverable screen instead
    // of an uncontrolled white screen.
    errorBuilder: (context, state) {
      return Scaffold(
        backgroundColor: AppColors.cream,
        body: Center(
          child: AppErrorState(
            title: 'مشکلی پیش آمد',
            message: 'این صفحه در دسترس نیست.',
            retryLabel: 'بازگشت به صفحه اصلی',
            onRetry: () => context.goNamed(AppRouteNames.workoutProgramsList),
          ),
        ),
      );
    },

    redirect: (context, state) {
      final authState = sl<AuthCubit>().state;
      final location = state.matchedLocation;

      final isSplash = location == AppRoutes.splash;
      final isAuthRoute =
          location == AppRoutes.login ||
          location == AppRoutes.forgotPassword ||
          location == AppRoutes.resetPassword;

      if (authState is AuthInitial || authState is AuthLoading) {
        return isSplash ? null : AppRoutes.splash;
      }

      final isAuthenticated = authState is AuthAuthenticated;

      if (!isAuthenticated) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      if (isAuthRoute || isSplash) {
        return AppRoutes.workoutProgramsList;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRouteNames.splash,
        parentNavigatorKey: navigatorKey,
        builder: (_, _) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRouteNames.login,
        parentNavigatorKey: navigatorKey,
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: AppRouteNames.forgotPassword,
        parentNavigatorKey: navigatorKey,
        builder: (_, _) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        name: AppRouteNames.resetPassword,
        parentNavigatorKey: navigatorKey,
        builder: (_, state) {
          final email = state.uri.queryParameters['email'];
          final token = state.uri.queryParameters['token'];
          return ResetPasswordPage(initialEmail: email, initialToken: token);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithBottomNav(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _programBranchNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.workoutProgramsList,
                name: AppRouteNames.workoutProgramsList,
                builder: (_, _) => const WorkoutProgramListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _exerciseBranchNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.exercises,
                name: AppRouteNames.exercises,
                builder: (_, _) => const ExerciseListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsBranchNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                name: AppRouteNames.settings,
                builder: (_, _) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoutes.createExercise,
        name: AppRouteNames.createExercise,
        parentNavigatorKey: navigatorKey,
        builder: (_, _) => const AddExercisePage(),
      ),

      // exerciseId is required routing state (path param). `extra` is
      // read only as an optional seed.
      GoRoute(
        path: AppRoutes.editExercise,
        name: AppRouteNames.editExercise,
        parentNavigatorKey: navigatorKey,
        builder: (_, state) {
          final exerciseId = state.pathParameters['exerciseId']!;
          final seed = state.extra;
          return EditExercisePage(
            exerciseId: exerciseId,
            seedExercise: seed is Exercise ? seed : null,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.createWorkoutProgram,
        name: AppRouteNames.createWorkoutProgram,
        parentNavigatorKey: navigatorKey,
        builder: (_, state) {
          // Edit mode is signalled by ?programId=... (URL-derivable),
          // not by extra.
          final programId = state.uri.queryParameters['programId'];
          final seed = state.extra;
          return CreateWorkoutProgramPage(
            programId: programId,
            seedProgram: seed is WorkoutProgram ? seed : null,
          );
        },
      ),

      // Program Detail + its entire internal flow. ProgramExerciseCubit
      // is scoped to this ShellRoute subtree so the Detail page and the
      // wizard share it.
      ShellRoute(
        parentNavigatorKey: navigatorKey,
        builder: (context, state, child) {
          return BlocProvider(
            create: (_) => sl<ProgramExerciseCubit>(),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.workoutProgramDetail,
            name: AppRouteNames.workoutProgramDetail,
            builder: (_, state) {
              final programId = state.pathParameters['programId']!;
              final seed = state.extra;
              return WorkoutProgramDetailPage(
                programId: programId,
                seedProgram: seed is WorkoutProgram ? seed : null,
              );
            },
            routes: [
              // Editing an EXISTING program exercise — single step,
              // keyed entirely by programExerciseId.
              GoRoute(
                path: 'program-exercises/:programExerciseId/edit',
                name: AppRouteNames.editProgramExercise,
                builder: (_, state) {
                  final programExerciseId =
                      state.pathParameters['programExerciseId']!;
                  final seed = state.extra;
                  return ExerciseConfigurationPage(
                    programExerciseId: programExerciseId,
                    seedDetails: seed is ProgramExerciseDetails ? seed : null,
                  );
                },
              ),

              // The ENTIRE add-exercise wizard lives behind this ONE
              // route/ONE URL. There is deliberately no nested GoRoute
              // per step — see ProgramExerciseWizardCubit for step
              // transitions — so there's nothing left for browser/system
              // Back to desynchronize from.
              GoRoute(
                path: 'program-exercises/create',
                name: AppRouteNames.createProgramExercise,
                builder: (_, state) {
                  final programId = state.pathParameters['programId']!;
                  final seed = state.extra;
                  return ProgramExerciseWizardPage(
                    programId: programId,
                    seedProgram: seed is WorkoutProgram ? seed : null,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
