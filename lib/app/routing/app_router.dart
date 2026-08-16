import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/app_routes.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_configuration_args.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_selection_args.dart';
import 'package:coach_studio/app/routing/scaffold_with_bottom_nav.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/presentation/pages/add_exercise_page.dart';
import 'package:coach_studio/features/exercises/presentation/pages/edit_exercise_page.dart';
import 'package:coach_studio/features/exercises/presentation/pages/exercise_list_page.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/add_program_exercise_item_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/create_program_exercise_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/create_workout_program_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/exercise_configuration_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_detail_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  // Root Navigator — internal pages are pushed onto this Navigator
  // instead of the branch Navigator.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  // Navigator dedicated to each Branch (optional, but recommended by go_router).
  static final GlobalKey<NavigatorState> _exerciseBranchNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'exerciseBranch');

  static final GlobalKey<NavigatorState> _programBranchNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'programBranch');

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.workoutProgramsList,

    routes: [
      // -----------------------------------------------------------------
      // Main tabs
      // -----------------------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithBottomNav(navigationShell: navigationShell);
        },

        branches: [
          // ---------------- Programs Branch ----------------
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

          // ---------------- Exercises Branch ----------------
          StatefulShellBranch(
            navigatorKey: _exerciseBranchNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.exercises,
                name: AppRouteNames.exercises,
                builder: (_, _) => const ExerciseListPage(),
                // Note: There are no child routes defined here.
                // Create/Edit routes are defined as top-level routes with parentNavigatorKey
                // so they are pushed onto the root Navigator and do not cover the BottomNav.
              ),
            ],
          ),
        ],
      ),

      // -----------------------------------------------------------------
      // Exercises internal pages — pushed onto the root Navigator (without BottomNav).
      // ExerciseCubit is provided globally in main.dart,
      // so context.read<ExerciseCubit>() here accesses the same instance used by the list page.
      // -----------------------------------------------------------------
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
          final exercise = state.extra as Exercise;
          return EditExercisePage(exercise: exercise);
        },
      ),

      // -----------------------------------------------------------------
      // Programs internal pages — pushed onto the root Navigator
      // instead of the Branch Navigator (without BottomNav).
      // -----------------------------------------------------------------
      GoRoute(
        path: AppRoutes.createWorkoutProgram,
        name: AppRouteNames.createWorkoutProgram,
        parentNavigatorKey: navigatorKey,
        builder: (_, state) {
          final program = state.extra as WorkoutProgram?;
          return CreateWorkoutProgramPage(existingProgram: program);
        },
      ),

      // Program Detail + its entire internal flow (create/select/configure)
      // uses a separate non-stateful ShellRoute on the root Navigator.
      // It is only used to provide a fresh instance of ProgramExerciseCubit
      // to this subtree. When the entire flow is popped, the Cubit is disposed
      // (according to the rule: state persistence across tabs is not required).
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
              final program = state.extra as WorkoutProgram;
              return WorkoutProgramDetailPage(program: program);
            },

            routes: [
              GoRoute(
                path: 'program-exercises/:programExerciseId/edit',
                name: AppRouteNames.editProgramExercise,
                builder: (_, state) {
                  final args = state.extra as ProgramExerciseConfigurationArgs;

                  return ExerciseConfigurationPage(
                    program: args.program,
                    draft: args.draft,
                    exercises: args.exercises,
                    existingExercise: args.existingExercise,
                  );
                },
              ),

              GoRoute(
                path: 'program-exercises/create',
                name: AppRouteNames.createProgramExercise,
                builder: (_, state) {
                  final program = state.extra as WorkoutProgram;
                  return CreateProgramExercisePage(program: program);
                },

                routes: [
                  GoRoute(
                    path: 'select',
                    name: AppRouteNames.addProgramExerciseItems,
                    builder: (_, state) {
                      final args = state.extra as ProgramExerciseSelectionArgs;
                      return AddProgramExerciseItemPage(
                        program: args.program,
                        draft: args.draft,
                      );
                    },
                  ),

                  GoRoute(
                    path: 'configure',
                    name: AppRouteNames.configureProgramExercise,
                    builder: (_, state) {
                      final args =
                          state.extra as ProgramExerciseConfigurationArgs;
                      return ExerciseConfigurationPage(
                        program: args.program,
                        draft: args.draft,
                        exercises: args.exercises,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
