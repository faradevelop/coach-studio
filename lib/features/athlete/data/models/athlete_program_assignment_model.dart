import 'package:coach_studio/features/athlete/domain/entities/athlete_program_assignment.dart';
import 'package:coach_studio/features/workout_programs/data/models/workout_program_model.dart';

class AthleteProgramAssignmentModel {
  final String id;
  final String athleteId;
  final String programId;
  final String? sourceProgramId;
  final String? sourceProgramTitle;
  final String assignedBy;
  final DateTime assignedAt;
  final DateTime? endedAt;
  final bool isCurrent;
  final WorkoutProgramModel? program;

  const AthleteProgramAssignmentModel({
    required this.id,
    required this.athleteId,
    required this.programId,
    this.sourceProgramId,
    this.sourceProgramTitle,
    required this.assignedBy,
    required this.assignedAt,
    this.endedAt,
    required this.isCurrent,
    this.program,
  });

  factory AthleteProgramAssignmentModel.fromJson(Map<String, dynamic> json) {
    final programJson = json['program'];
    final sourceJson = json['sourceProgram'];
    return AthleteProgramAssignmentModel(
      id: json['id'] as String,
      athleteId: json['athleteId'] as String,
      programId: json['programId'] as String,
      sourceProgramId: json['sourceProgramId'] as String?,
      sourceProgramTitle: sourceJson is Map<String, dynamic>
          ? sourceJson['title'] as String?
          : null,
      assignedBy: json['assignedBy'] as String,
      assignedAt: DateTime.parse(json['assignedAt'] as String).toLocal(),
      endedAt: json['endedAt'] != null
          ? DateTime.parse(json['endedAt'] as String).toLocal()
          : null,
      isCurrent: json['isCurrent'] as bool? ?? json['endedAt'] == null,
      program: programJson is Map<String, dynamic>
          ? WorkoutProgramModel.fromJson(programJson)
          : null,
    );
  }

  AthleteProgramAssignment toEntity() => AthleteProgramAssignment(
    id: id,
    athleteId: athleteId,
    programId: programId,
    sourceProgramId: sourceProgramId,
    sourceProgramTitle: sourceProgramTitle,
    assignedBy: assignedBy,
    assignedAt: assignedAt,
    endedAt: endedAt,
    isCurrent: isCurrent,
    program: program?.toEntity(),
  );
}