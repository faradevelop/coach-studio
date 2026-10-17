import 'dart:typed_data';

import 'package:coach_studio/features/workout_programs/domain/entities/athlete_info.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_details.dart';

/// Plain, isolate-sendable payload for PDF generation.
///
/// Only primitives, [ByteData], and simple entities (Strings, ints, enums,
/// DateTime) are included here so this object can safely cross an isolate
/// boundary on native platforms (see `pdf_executor_io.dart`). Flutter-bound
/// objects such as `pw.Font` / `pw.MemoryImage` are intentionally NOT stored
/// here — they are reconstructed from raw bytes inside `buildPdfDocument`,
/// which is safe to run either on the main thread (Web) or inside a
/// background isolate (native).
class PdfBuildInput {
  final WorkoutProgramDetails details;
  final AthleteInfo athlete;

  final ByteData regularFontData;
  final ByteData boldFontData;
  final ByteData logoData;
  final ByteData instagramData;
  final ByteData phoneData;
  final ByteData muscleData;

  /// When true, [buildPdfDocument] yields to the event loop between pages
  /// so the UI (e.g. a loading animation) keeps repainting. This only
  /// matters on Flutter Web, where PDF generation always runs on the main
  /// thread. Native platforms run this off the main thread entirely (via
  /// `compute()`), so this should be false there.
  final bool shouldYield;

  const PdfBuildInput({
    required this.details,
    required this.athlete,
    required this.regularFontData,
    required this.boldFontData,
    required this.logoData,
    required this.instagramData,
    required this.phoneData,
    required this.muscleData,
    required this.shouldYield,
  });
}
