import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';

class AthleteProgramAssignment {
  final String id;
  final String athleteId;
  final String programId;
  final String? sourceProgramId;
  final String? sourceProgramTitle; // null if the source was deleted later
  final String assignedBy;
  final DateTime assignedAt;
  final DateTime? endedAt;
  final bool isCurrent;
  final WorkoutProgram? program;

  const AthleteProgramAssignment({
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
}
