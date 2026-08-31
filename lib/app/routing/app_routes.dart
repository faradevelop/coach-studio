abstract final class AppRoutes {
  AppRoutes._();

  // Authentication

  static const splash = '/splash';

  static const login = '/login';

  static const forgotPassword = '/forgot-password';

  static const resetPassword = '/reset-password';

  static const settings = '/settings';

  // Workout Programs

  static const workoutProgramsList = '/programs';

  static const createWorkoutProgram = '/programs/create';

  static const workoutProgramDetail = '/programs/:programId';

  // Exercises

  static const exercises = '/exercises';

  static const createExercise = '/exercises/create';

  static const editExercise = '/exercises/:exerciseId/edit';
}
