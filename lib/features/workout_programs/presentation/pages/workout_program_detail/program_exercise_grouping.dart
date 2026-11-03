import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';

extension ProgramExerciseGrouping on List<ProgramExerciseDetails> {
  /// Groups exercises by day (every day in 1..[days] is present, even if
  /// empty) and sorts each day's exercises by their order.
  Map<int, List<ProgramExerciseDetails>> groupByDay(int days) {
    final grouped = <int, List<ProgramExerciseDetails>>{
      for (int day = 1; day <= days; day++) day: [],
    };

    for (final exercise in this) {
      grouped.putIfAbsent(exercise.programExercise.day, () => []).add(exercise);
    }

    for (final list in grouped.values) {
      list.sort(
        (a, b) => a.programExercise.order.compareTo(b.programExercise.order),
      );
    }

    return grouped;
  }
}
