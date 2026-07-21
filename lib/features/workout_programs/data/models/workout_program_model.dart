import 'package:cloud_firestore/cloud_firestore.dart';
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

  const WorkoutProgramModel({
    required this.id,
    required this.title,
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    this.notes,
    required this.isTemplate,
  });

  factory WorkoutProgramModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;

    return WorkoutProgramModel(
      id: doc.id,
      title: data['title'],
      goal: ProgramGoal.values.byName(data['goal']),
      level: ProgramLevel.values.byName(data['level']),
      daysPerWeek: data['daysPerWeek'],
      notes: data['notes'],
      isTemplate: data['isTemplate'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'goal': goal.name,
      'level': level.name,
      'daysPerWeek': daysPerWeek,
      'notes': notes,
      'isTemplate': isTemplate,
    };
  }

  WorkoutProgramModel copyWith({
    String? id,
    String? title,
    ProgramGoal? goal,
    ProgramLevel? level,
    int? daysPerWeek,
    String? notes,
    bool? isTemplate,
  }) {
    return WorkoutProgramModel(
      id: id ?? this.id,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      level: level ?? this.level,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      notes: notes ?? this.notes,
      isTemplate: isTemplate ?? this.isTemplate,
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
    );
  }
}
