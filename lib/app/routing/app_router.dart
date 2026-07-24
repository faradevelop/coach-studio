import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/app_routes.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_configuration_args.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_selection_args.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/add_program_exercise_item_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/create_program_exercise_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/create_workout_program_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/exercise_configuration_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_detail_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_list_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation:
        AppRoutes.workoutProgramsList, // workoutPrograms = '/programs'

    routes: [
      GoRoute(
        path: AppRoutes.workoutProgramsList,
        name: AppRouteNames.workoutPrograms,
        builder: (_, __) {
          return BlocProvider(
            create: (_) => sl<WorkoutProgramCubit>()..loadPrograms(),
            child: const WorkoutProgramListPage(),
          );
        },
      ),

      GoRoute(
        path: AppRoutes
            .createWorkoutProgram, //  createWorkoutProgram = '/programs/create'
        name: AppRouteNames.createWorkoutProgram,
        builder: (_, state) {
          final program = state.extra as WorkoutProgram?;

          return BlocProvider(
            create: (_) => sl<WorkoutProgramCubit>(),
            child: CreateWorkoutProgramPage(existingProgram: program),
          );
        },
      ),

      ShellRoute(
        builder: (context, state, child) {
          return BlocProvider(
            create: (_) => sl<ProgramExerciseCubit>(),

            child: child,
          );
        },

        routes: [
          GoRoute(
            path: AppRoutes
                .workoutProgramDetail, //workoutProgramDetail = '/programs/:programId'
            name: AppRouteNames.workoutProgramDetail,

            builder: (_, state) {
              final program = state.extra as WorkoutProgram;

              return WorkoutProgramDetailPage(program: program);
            },

            routes: [
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

                      return BlocProvider(
                        create: (_) => sl<ExerciseCubit>()..loadExercises(),
                        child: AddProgramExerciseItemPage(
                          program: args.program,
                          draft: args.draft,
                        ),
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
