import 'package:coach_studio/features/athlete/presentation/cubit/athlete_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AthleteCubit extends Cubit<AthleteState> {
  AthleteCubit() : super(AthleteInitial());
}
