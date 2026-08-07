// lib/features/workout_programs/data/services/pdf_generation/pdf_executor_io.dart
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;

import 'pdf_build_input.dart';
import 'pdf_document_builder.dart';

/// Native (Android/iOS/desktop) execution strategy.
///
/// Runs the pure, Flutter-binding-free [buildPdfDocument] function in a
/// real background isolate via [compute]. The UI thread is never touched
/// by the CPU-heavy work, so no chunking/yielding is needed here — that's
/// only a Web concern (see pdf_executor_web.dart).
///
/// [PdfBuildInput] only carries isolate-sendable data (ByteData, plain
/// entities), so it crosses the isolate boundary safely.
Future<Uint8List> executePdfGeneration(PdfBuildInput input) {
  return compute(buildPdfDocument, input);
}
