abstract final class AppRoutes {
  AppRoutes._();

  // Workout Programs

  static const workoutProgramsList = '/programs';

  static const createWorkoutProgram = '/programs/create';

  static const workoutProgramDetail = '/programs/:programId';

  // Exercises

  static const exercises = '/exercises';

  static const createExercise = '/exercises/create';

  static const editExercise = '/exercises/:exerciseId/edit';
}
