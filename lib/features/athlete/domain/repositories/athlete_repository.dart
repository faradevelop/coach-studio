import 'package:coach_studio/features/athlete/domain/entities/athlete.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_filter.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_program_assignment.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_summary.dart';

abstract class AthleteRepository {
  Future<List<Athlete>> getAthletes(AthleteFilter filter);
  Future<AthleteSummary> getSummary();
  Future<Athlete> getAthlete(String id);
  Future<Athlete> createAthlete(Athlete athlete);
  Future<Athlete> updateAthlete(Athlete athlete);
  Future<Athlete> archiveAthlete(String id);
  Future<Athlete> restoreAthlete(String id);
  Future<List<AthleteProgramAssignment>> getProgramHistory(String athleteId);
  Future<AthleteProgramAssignment> assignProgram(
    String athleteId,
    String sourceProgramId, {
    String? title,
  });
}
