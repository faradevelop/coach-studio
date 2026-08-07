// lib/features/workout_programs/data/services/pdf_generation/pdf_executor_web.dart
import 'dart:typed_data';

import 'pdf_build_input.dart';
import 'pdf_document_builder.dart';

/// Flutter Web execution strategy.
///
/// `dart:isolate` / `compute()` cannot offload work on Web — Flutter's own
/// `compute()` just invokes the callback directly on the main thread there,
/// so it provides no real benefit and is intentionally not used here.
///
/// Instead, [buildPdfDocument] itself yields to the event loop between
/// pages when [PdfBuildInput.shouldYield] is true (set by
/// WorkoutProgramPdfGenerator based on `kIsWeb`), which keeps the UI
/// (e.g. a loading animation) repainting between chunks. The final
/// `doc.save()` call remains one unavoidable synchronous block — see the
/// note in pdf_document_builder.dart.
Future<Uint8List> executePdfGeneration(PdfBuildInput input) {
  return buildPdfDocument(input);
}
