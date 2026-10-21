import 'package:coach_studio/features/athlete/domain/entities/athlete_program_assignment.dart';
import 'package:coach_studio/features/athlete/domain/enums/gender.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';

class Athlete {
  final String id;
  final String coachId;
  final String firstName;
  final String lastName;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String? phone;
  final String? email;
  final int? heightCm;
  final double? weightKg;
  final ProgramGoal? fitnessGoal;
  final ProgramLevel? experienceLevel;
  final String? injuries;
  final String? physicalLimitations;
  final String? coachNotes;
  final bool isArchived;
  final DateTime? archivedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final AthleteProgramAssignment? currentAssignment;

  const Athlete({
    required this.id,
    required this.coachId,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.dateOfBirth,
    this.phone,
    this.email,
    this.heightCm,
    this.weightKg,
    this.fitnessGoal,
    this.experienceLevel,
    this.injuries,
    this.physicalLimitations,
    this.coachNotes,
    this.isArchived = false,
    this.archivedAt,
    this.createdAt,
    this.updatedAt,
    this.currentAssignment,
  });

  String get fullName => '$firstName $lastName'.trim();

  int? get age {
    final dob = dateOfBirth;
    if (dob == null) return null;
    final now = DateTime.now();
    var years = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      years--;
    }
    return years;
  }
}
