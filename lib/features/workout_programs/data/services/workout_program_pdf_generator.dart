// lib/features/workout_programs/data/services/workout_program_pdf_generator.dart
import 'dart:typed_data';

import 'package:coach_studio/core/constants/club_info.dart';
import 'package:coach_studio/features/workout_programs/data/services/pdf_generation/pdf_build_input.dart';
import 'package:coach_studio/features/workout_programs/data/services/pdf_generation/pdf_executor.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/athlete_info.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_details.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;

/// Loads the fonts/assets needed for the workout-program PDF (this part
/// must stay on the main isolate since it depends on `rootBundle`), then
/// hands off the actual PDF building to a platform-specific execution
/// strategy:
/// - Native: a real background isolate (see pdf_generation/pdf_executor_io.dart)
/// - Web: chunked/yielded generation on the main thread
///   (see pdf_generation/pdf_executor_web.dart)
///
/// The PDF layout/content itself is unchanged and now lives in
/// pdf_generation/pdf_document_builder.dart.
class WorkoutProgramPdfGenerator {
  Future<Uint8List> generate({
    required WorkoutProgramDetails details,
    required AthleteInfo athlete,
  }) async {
    final regularFontData = await rootBundle.load(
      'assets/fonts/Vazirmatn-Regular.ttf',
    );
    final boldFontData = await rootBundle.load(
      'assets/fonts/Vazirmatn-Bold.ttf',
    );
    final logoData = await rootBundle.load(ClubInfo.logoAsset);
    final instagramData = await rootBundle.load(ClubInfo.instagramAsset);
    final phoneData = await rootBundle.load(ClubInfo.phoneAsset);
    final muscleData = await rootBundle.load(ClubInfo.muscleAsset);

    final input = PdfBuildInput(
      details: details,
      athlete: athlete,
      regularFontData: regularFontData,
      boldFontData: boldFontData,
      logoData: logoData,
      instagramData: instagramData,
      phoneData: phoneData,
      muscleData: muscleData,
      // Only Web needs to yield between pages to keep the UI responsive —
      // native platforms offload the work to a real background isolate
      // instead (see pdf_executor_io.dart / pdf_executor_web.dart).
      shouldYield: kIsWeb,
    );

    return executePdfGeneration(input);
  }
}
