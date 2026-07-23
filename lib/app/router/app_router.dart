import 'package:coach_studio/features/workout_programs/presentation/pages/create_workout_program_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_list_page.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.workoutPrograms,

  routes: [
    GoRoute(
      path: AppRoutes.workoutPrograms,
      name: AppRoutes.workoutProgramsName,

      builder: (context, state) {
        return const WorkoutProgramListPage();
      },
    ),

    GoRoute(
      path: AppRoutes.createWorkoutProgram,
      name: AppRoutes.createWorkoutProgramName,

      builder: (context, state) {
        return const CreateWorkoutProgramPage();
      },
    ),
  ],
);
