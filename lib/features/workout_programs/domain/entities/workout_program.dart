import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';

class WorkoutProgram {
  final String id;
  final String title;
  final ProgramGoal goal;
  final ProgramLevel level;
  final int daysPerWeek;
  final String? notes;
  final bool isTemplate;
  final String? athleteId;
  final String? athleteName;

  const WorkoutProgram({
    required this.id,
    required this.title,
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    this.notes,
    required this.isTemplate,
    this.athleteId,
    this.athleteName,
  });

  WorkoutProgram copyWith({
    String? id,
    String? title,
    ProgramGoal? goal,
    ProgramLevel? level,
    int? daysPerWeek,
    String? notes,
    bool? isTemplate,
    String? athleteId,
    String? athleteName,
  }) {
    return WorkoutProgram(
      id: id ?? this.id,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      notes: notes ?? this.notes,
      isTemplate: isTemplate ?? this.isTemplate,
      athleteId: athleteId ?? this.athleteId,
      athleteName: athleteName ?? this.athleteName,
    );
  }
}
