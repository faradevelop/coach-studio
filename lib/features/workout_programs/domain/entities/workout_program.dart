import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';

class WorkoutProgram {
  final String id;

  final String title;

  final ProgramGoal goal;

  final ProgramLevel level;

  final int daysPerWeek;

  final String notes;

  final bool isTemplate;

  const WorkoutProgram({
    required this.id,
    required this.title,
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    required this.notes,
    required this.isTemplate,
  });
}
