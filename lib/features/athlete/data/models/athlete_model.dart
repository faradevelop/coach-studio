import 'package:coach_studio/features/athlete/data/models/athlete_program_assignment_model.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete.dart';
import 'package:coach_studio/features/athlete/domain/enums/gender.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';

class AthleteModel {
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
  final AthleteProgramAssignmentModel? currentAssignment;

  const AthleteModel({
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

  factory AthleteModel.fromEntity(Athlete e) => AthleteModel(
    id: e.id,
    coachId: e.coachId,
    firstName: e.firstName,
    lastName: e.lastName,
    gender: e.gender,
    dateOfBirth: e.dateOfBirth,
    phone: e.phone,
    email: e.email,
    heightCm: e.heightCm,
    weightKg: e.weightKg,
    fitnessGoal: e.fitnessGoal,
    experienceLevel: e.experienceLevel,
    injuries: e.injuries,
    physicalLimitations: e.physicalLimitations,
    coachNotes: e.coachNotes,
    isArchived: e.isArchived,
  );

  Athlete toEntity() => Athlete(
    id: id,
    coachId: coachId,
    firstName: firstName,
    lastName: lastName,
    gender: gender,
    dateOfBirth: dateOfBirth,
    phone: phone,
    email: email,
    heightCm: heightCm,
    weightKg: weightKg,
    fitnessGoal: fitnessGoal,
    experienceLevel: experienceLevel,
    injuries: injuries,
    physicalLimitations: physicalLimitations,
    coachNotes: coachNotes,
    isArchived: isArchived,
    archivedAt: archivedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    currentAssignment: currentAssignment?.toEntity(),
  );

  factory AthleteModel.fromJson(Map<String, dynamic> json) {
    final assignment = json['currentAssignment'];
    return AthleteModel(
      id: json['id'] as String,
      coachId: json['coachId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      gender: json['gender'] != null
          ? Gender.values.byName(json['gender'] as String)
          : null,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      heightCm: (json['heightCm'] as num?)?.toInt(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      fitnessGoal: json['fitnessGoal'] != null
          ? ProgramGoal.values.byName(json['fitnessGoal'] as String)
          : null,
      experienceLevel: json['experienceLevel'] != null
          ? ProgramLevel.values.byName(json['experienceLevel'] as String)
          : null,
      injuries: json['injuries'] as String?,
      physicalLimitations: json['physicalLimitations'] as String?,
      coachNotes: json['coachNotes'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'] as String).toLocal()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String).toLocal()
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String).toLocal()
          : null,
      currentAssignment: assignment is Map<String, dynamic>
          ? AthleteProgramAssignmentModel.fromJson(assignment)
          : null,
    );
  }

  /// `coachId` is deliberately never sent: the Backend resolves the owner.
  Map<String, dynamic> toRequestJson() {
    final dob = dateOfBirth;
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender?.name,
      'dateOfBirth': dob == null
          ? null
          : '${dob.year.toString().padLeft(4, '0')}-'
                '${dob.month.toString().padLeft(2, '0')}-'
                '${dob.day.toString().padLeft(2, '0')}',
      'phone': phone,
      'email': email,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'fitnessGoal': fitnessGoal?.name,
      'experienceLevel': experienceLevel?.name,
      'injuries': injuries,
      'physicalLimitations': physicalLimitations,
      'coachNotes': coachNotes,
    };
  }
}
