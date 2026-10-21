import 'package:coach_studio/features/athlete/domain/entities/athlete.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_program_assignment.dart';

sealed class AthleteDetailState {}

class AthleteDetailLoading extends AthleteDetailState {}

class AthleteDetailLoaded extends AthleteDetailState {
  final Athlete athlete;
  final List<AthleteProgramAssignment> history;
  final bool isSubmitting;

  AthleteDetailLoaded({
    required this.athlete,
    required this.history,
    this.isSubmitting = false,
  });

  AthleteDetailLoaded copyWith({
    Athlete? athlete,
    List<AthleteProgramAssignment>? history,
    bool? isSubmitting,
  }) => AthleteDetailLoaded(
    athlete: athlete ?? this.athlete,
    history: history ?? this.history,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}

class AthleteDetailError extends AthleteDetailState {
  final String message;
  AthleteDetailError(this.message);
}
