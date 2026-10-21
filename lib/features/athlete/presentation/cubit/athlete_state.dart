import 'package:coach_studio/features/athlete/domain/athlete.dart';

sealed class AthleteState {}

class AthleteInitial extends AthleteState {}

class AthleteLoading extends AthleteState {}

class AthleteLoaded extends AthleteState {
  final List<Athlete> athletes;

  AthleteLoaded({required this.athletes});
}

class AthleteError extends AthleteState {
  final String message;

  AthleteError(this.message);
}
