import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';

class WorkoutProgramModel {
  final String id;
  final String title;
  final ProgramGoal goal;
  final ProgramLevel level;
  final int daysPerWeek;
  final String? notes;
  final bool isTemplate;
  final String? athleteId;
  final String? athleteName;

  const WorkoutProgramModel({
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

  WorkoutProgramModel copyWith({
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
    return WorkoutProgramModel(
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

  factory WorkoutProgramModel.fromEntity(WorkoutProgram entity) {
    return WorkoutProgramModel(
      id: entity.id,
      title: entity.title,
      goal: entity.goal,
      level: entity.level,
      daysPerWeek: entity.daysPerWeek,
      notes: entity.notes,
      isTemplate: entity.isTemplate,
      athleteId: entity.athleteId,
      athleteName: entity.athleteName,
    );
  }

  WorkoutProgram toEntity() {
    return WorkoutProgram(
      id: id,
      title: title,
      goal: goal,
      level: level,
      daysPerWeek: daysPerWeek,
      notes: notes,
      isTemplate: isTemplate,
      athleteId: athleteId,
      athleteName: athleteName,
    );
  }

  factory WorkoutProgramModel.fromJson(Map<String, dynamic> json) {
    final athlete = json['athlete'];
    return WorkoutProgramModel(
      id: json['id'] as String,
      title: json['title'] as String,
      goal: ProgramGoal.values.byName(json['goal'] as String),
      level: ProgramLevel.values.byName(json['level'] as String),
      daysPerWeek: json['daysPerWeek'] as int,
      notes: json['notes'] as String?,
      isTemplate: json['isTemplate'] as bool,
      athleteId: json['athleteId'] as String?,
      athleteName: athlete is Map<String, dynamic>
          ? athlete['fullName'] as String?
          : null,
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'title': title,
      'goal': goal.name,
      'level': level.name,
      'daysPerWeek': daysPerWeek,
      'notes': notes,
    };
  }
}
