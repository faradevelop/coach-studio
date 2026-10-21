import 'package:coach_studio/features/athlete/domain/entities/athlete.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_summary.dart';

sealed class AthleteState {}

class AthleteInitial extends AthleteState {}

class AthleteLoading extends AthleteState {}

class AthleteLoaded extends AthleteState {
  final List<Athlete> athletes;
  final AthleteSummary? summary;

  AthleteLoaded({required this.athletes, this.summary});
}

class AthleteError extends AthleteState {
  final String message;

  AthleteError(this.message);
}
