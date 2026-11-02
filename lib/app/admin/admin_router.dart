import 'package:coach_studio/app/admin/admin_shell.dart';
import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/app_routes.dart';
import 'package:coach_studio/app/routing/go_router_refresh_stream.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_state.dart';
import 'package:coach_studio/features/authentication/presentation/pages/forgot_password_page.dart';
import 'package:coach_studio/features/authentication/presentation/pages/login_page.dart';
import 'package:coach_studio/features/authentication/presentation/pages/reset_password_page.dart';
import 'package:coach_studio/features/authentication/presentation/pages/splash_page.dart';
import 'package:coach_studio/features/coaches/presentation/pages/coach_detail_page.dart';
import 'package:coach_studio/features/coaches/presentation/pages/coach_list_page.dart';
import 'package:coach_studio/features/coaches/presentation/pages/create_coach_page.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/presentation/pages/add_exercise_page.dart';
import 'package:coach_studio/features/exercises/presentation/pages/edit_exercise_page.dart';
import 'package:coach_studio/features/exercises/presentation/pages/exercise_detail_page.dart';
import 'package:coach_studio/features/exercises/presentation/pages/exercise_list_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Router of the Admin web app. Route NAMES/PATHS are shared with the coach
/// app's constants so shared pages (login, exercise list/forms) work unchanged.
/// Only two areas exist: Exercises and Coaches (no dashboard).
class AdminRouter {
  AdminRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'adminRoot');
  static final _exercisesBranchKey = GlobalKey<NavigatorState>(
    debugLabel: 'adminExercises',
  );
  static final _coachesBranchKey = GlobalKey<NavigatorState>(
    debugLabel: 'adminCoaches',
  );

  /// Only same-app paths are accepted; auth/splash pages are never a target.
  static String? _safeFrom(String? from) {
    if (from == null || !from.startsWith('/') || from.startsWith('//')) {
      return null;
    }
    final path = Uri.tryParse(from)?.path;
    const blocked = {
      AppRoutes.splash,
      AppRoutes.login,
      AppRoutes.forgotPassword,
      AppRoutes.resetPassword,
    };
    if (path == null || blocked.contains(path)) return null;
    return from;
  }

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(sl<AuthCubit>().stream),
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AppErrorState(
          title: 'مشکلی پیش آمد',
          message: 'این صفحه در دسترس نیست.',
          retryLabel: 'بازگشت به تمرین‌ها',
          onRetry: () => context.goNamed(AppRouteNames.exercises),
        ),
      ),
    ),

    redirect: (context, state) {
      final authState = sl<AuthCubit>().state;
      final location = state.matchedLocation;

      final isSplash = location == AppRoutes.splash;
      final isResetRoute = location == AppRoutes.resetPassword;
      final isAuthRoute =
          location == AppRoutes.login ||
          location == AppRoutes.forgotPassword ||
          isResetRoute;

      // Session restoration in progress.
      if (authState is AuthInitial || authState is AuthLoading) {
        // The reset link must keep its ?email=&token= query.
        if (isSplash || isResetRoute) return null;
        // Remember the wanted location so a refresh / deep link survives the splash.
        return Uri(
          path: AppRoutes.splash,
          queryParameters: {'from': state.uri.toString()},
        ).toString();
      }

      if (authState is! AuthAuthenticated) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      // Authenticated.
      if (isSplash) {
        return _safeFrom(state.uri.queryParameters['from']) ??
            AppRoutes.exercises;
      }
      if (isAuthRoute) return AppRoutes.exercises;
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
        builder: (_, state) => ResetPasswordPage(
          initialEmail: state.uri.queryParameters['email'],
          initialToken: state.uri.queryParameters['token'],
        ),
      ),

      // Branch order MUST match destination order in AdminShell.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AdminShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _exercisesBranchKey,
            routes: [
              GoRoute(
                path: AppRoutes.exercises,
                name: AppRouteNames.exercises,
                builder: (_, _) => const ExerciseListPage(canManage: true),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _coachesBranchKey,
            routes: [
              GoRoute(
                path: AppRoutes.coaches,
                name: AppRouteNames.coaches,
                builder: (_, _) => const CoachListPage(),
              ),
            ],
          ),
        ],
      ),

      // Full-page routes. `create` MUST stay above the `:id` routes.
      GoRoute(
        path: AppRoutes.createExercise,
        name: AppRouteNames.createExercise,
        parentNavigatorKey: navigatorKey,
        builder: (_, _) => const AddExercisePage(),
      ),
      GoRoute(
        path: AppRoutes.editExercise,
        name: AppRouteNames.editExercise,
        parentNavigatorKey: navigatorKey,
        builder: (_, state) {
          final seed = state.extra;
          return EditExercisePage(
            exerciseId: state.pathParameters['exerciseId']!,
            seedExercise: seed is Exercise ? seed : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.exerciseDetail,
        name: AppRouteNames.exerciseDetail,
        parentNavigatorKey: navigatorKey,
        builder: (_, state) {
          final seed = state.extra;
          return ExerciseDetailPage(
            exerciseId: state.pathParameters['exerciseId']!,
            seedExercise: seed is Exercise ? seed : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createCoach,
        name: AppRouteNames.createCoach,
        parentNavigatorKey: navigatorKey,
        builder: (_, _) => const CreateCoachPage(),
      ),
      GoRoute(
        path: AppRoutes.coachDetail,
        name: AppRouteNames.coachDetail,
        parentNavigatorKey: navigatorKey,
        builder: (_, state) {
          final seed = state.extra;
          return CoachDetailPage(
            coachId: state.pathParameters['coachId']!,
            seedCoach: seed is AuthUser ? seed : null,
          );
        },
      ),
    ],
  );
}
