import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/app_routes.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_configuration_args.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_selection_args.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/add_program_exercise_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/create_program_exercise_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/create_workout_program_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/exercise_configuration_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_detail_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_list_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.workoutPrograms,

    routes: [
      GoRoute(
        path: AppRoutes.workoutPrograms,
        name: AppRouteNames.workoutPrograms,
        builder: (_, __) {
          return const WorkoutProgramListPage();
        },
      ),

      GoRoute(
        path: AppRoutes.createWorkoutProgram,
        name: AppRouteNames.createWorkoutProgram,
        builder: (_, __) {
          return const CreateWorkoutProgramPage();
        },
      ),

      GoRoute(
        path: AppRoutes.workoutProgramDetail,
        name: AppRouteNames.workoutProgramDetail,
        builder: (_, state) {
          // TODO: use the extension method below for type-safe access to the extra property of GoRouterState
          //final program = state.extraAs<WorkoutProgram>();
          final program = state.extra as WorkoutProgram;

          return WorkoutProgramDetailPage(program: program);
        },
      ),

      GoRoute(
        path: AppRoutes.createProgramExercise,
        name: AppRouteNames.createProgramExercise,
        builder: (_, state) {
          final program = state.extra as WorkoutProgram;

          return CreateProgramExercisePage(program: program);
        },
      ),

      GoRoute(
        path: AppRoutes.addProgramExerciseItems,
        name: AppRouteNames.addProgramExerciseItems,

        builder: (_, state) {
          final args = state.extra as ProgramExerciseSelectionArgs;

          return AddProgramExercisePage(
            program: args.program,
            draft: args.draft,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.configureProgramExercise,
        name: AppRouteNames.configureProgramExercise,

        builder: (_, state) {
          final args = state.extra as ProgramExerciseConfigurationArgs;

          return ExerciseConfigurationPage(
            program: args.program,
            draft: args.draft,
            exercises: args.exercises,
          );
        },
      ),
    ],
  );
}

// TODO: for type-safe access to the extra property of GoRouterState
// extension GoRouterStateX on GoRouterState {
//   T extraAs<T>() {
//     final extra = this.extra;

//     if (extra is! T) {
//       throw Exception(
//         'Invalid route extra. Expected $T',
//       );
//     }

//     return extra;
//   }
// }
