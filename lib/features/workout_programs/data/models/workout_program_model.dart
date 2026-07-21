import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';

class WorkoutProgramModel extends WorkoutProgram {
  const WorkoutProgramModel({
    required super.id,
    required super.title,
    required super.goal,
    required super.level,
    required super.daysPerWeek,
    required super.notes,
    required super.isTemplate,
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
}
