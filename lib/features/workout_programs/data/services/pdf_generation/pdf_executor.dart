// lib/features/workout_programs/data/services/pdf_generation/pdf_executor.dart
//
// Platform-conditional execution strategy for PDF building.
//
// - On Web (dart:io unavailable): pdf_executor_web.dart — runs on the main
//   thread, relying on `PdfBuildInput.shouldYield` inside buildPdfDocument
//   to keep the UI responsive between pages.
// - On native platforms (dart:io available): pdf_executor_io.dart — runs
//   inside a real background isolate via compute(), never touching the UI
//   thread.
//
// Both files expose the same signature:
//   Future<Uint8List> executePdfGeneration(PdfBuildInput input)
// so callers (WorkoutProgramPdfGenerator) never need to know which platform
// they're on.
export 'pdf_executor_web.dart' if (dart.library.io) 'pdf_executor_io.dart';
