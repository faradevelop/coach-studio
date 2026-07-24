import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/app_routes.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/create_workout_program_page.dart';
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
        builder: (_, __) => const WorkoutProgramListPage(),
      ),

      GoRoute(
        path: AppRoutes.createWorkoutProgram,
        name: AppRouteNames.createWorkoutProgram,
        builder: (_, __) => const CreateWorkoutProgramPage(),
      ),
    ],
  );
}
