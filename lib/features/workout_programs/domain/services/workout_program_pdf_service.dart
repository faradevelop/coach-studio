import 'dart:typed_data';

import 'package:coach_studio/features/workout_programs/domain/entities/athlete_info.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_details.dart';

abstract interface class WorkoutProgramPdfService {
  Future<Uint8List> generate({
    required WorkoutProgramDetails details,
    required AthleteInfo athlete,
  });
}
