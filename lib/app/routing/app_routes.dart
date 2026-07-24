abstract final class AppRoutes {
  AppRoutes._();

  // Workout Programs

  static const workoutPrograms = '/programs';

  static const createWorkoutProgram = '/programs/create';

  static const workoutProgramDetail = '/programs/:programId';

  // Program Exercises

  static const createProgramExercise =
      '/programs/:programId/program-exercises/create';

  static const addProgramExerciseItems =
      '/program-exercises/:programExerciseId/items';

  static const configureProgramExercise =
      '/program-exercises/:programExerciseId/configure';
}
