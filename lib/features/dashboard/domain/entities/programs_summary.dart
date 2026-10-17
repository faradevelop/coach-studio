import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';

/// Pure aggregate over the programs list. Template is a *category* of
/// program (WorkoutProgram.isTemplate), not a status.
class ProgramsSummary {
  final int total;
  final int templates;

  const ProgramsSummary({required this.total, required this.templates});

  int get regular => total - templates;

  factory ProgramsSummary.fromPrograms(List<WorkoutProgram> programs) {
    return ProgramsSummary(
      total: programs.length,
      templates: programs.where((p) => p.isTemplate).length,
    );
  }
}
