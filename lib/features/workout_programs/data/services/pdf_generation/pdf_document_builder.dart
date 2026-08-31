// lib/features/workout_programs/data/services/pdf_generation/pdf_document_builder.dart
//
// Pure PDF-building logic, extracted as-is from WorkoutProgramPdfGenerator.
// This file has no dependency on Flutter bindings (no rootBundle, no
// BuildContext), which is what makes buildPdfDocument() safe to run inside
// a background isolate via compute() on native platforms. On Flutter Web,
// the same function runs on the main thread but yields to the event loop
// between pages when `input.shouldYield` is true.
import 'dart:typed_data';

import 'package:coach_studio/core/constants/club_info.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/athlete_info.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_item.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_details.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shamsi_date/shamsi_date.dart';

import 'pdf_build_input.dart';

// نسبت عرض ستون‌ها
const _numberFlex = 1;
//const _imageFlex = 2;
const _nameFlex = 7; //+2 from image flex
const _setsFlex = 1;
const _repsFlex = 3;
const _tempoFlex = 2;
const _restFlex = 2;
const _systemFlex = 2;

const _black = PdfColor.fromInt(0xFF2B2B2B);
const _orange = PdfColor.fromInt(0xFFf88709);
const _light = PdfColor.fromInt(0xFFfef4ea);
const _grey = PdfColor.fromInt(0xFFE8E8E8);
const _darkGrey = PdfColors.grey300;

const double _rowHeight = 36.0;
const double _subRowHeight = 32.0;

// container and clipRRect radius
const double _cardRadius = 4.0;

/// Builds the full workout-program PDF and returns its bytes.
///
/// This is the single function used by both execution strategies:
/// - Native: called inside a background isolate via `compute()`.
/// - Web: called directly on the main thread, yielding between pages when
///   `input.shouldYield` is true.
Future<Uint8List> buildPdfDocument(PdfBuildInput input) async {
  final details = input.details;
  final athlete = input.athlete;

  final regularFont = pw.Font.ttf(input.regularFontData);
  final boldFont = pw.Font.ttf(input.boldFontData);
  final logo = pw.MemoryImage(input.logoData.buffer.asUint8List());
  final instagram = pw.MemoryImage(input.instagramData.buffer.asUint8List());
  final phone = pw.MemoryImage(input.phoneData.buffer.asUint8List());
  final muscle = pw.MemoryImage(input.muscleData.buffer.asUint8List());

  final imageCache = await _prefetchExerciseImages(details.exercises);

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
  );

  final byDay = <int, List<ProgramExerciseDetails>>{};
  for (final e in details.exercises) {
    byDay.putIfAbsent(e.programExercise.day, () => []).add(e);
  }
  for (final list in byDay.values) {
    list.sort(
      (a, b) => a.programExercise.order.compareTo(b.programExercise.order),
    );
  }
  final days = byDay.keys.toList()..sort();

  for (var i = 0; i < days.length; i++) {
    final currentDay = days[i];
    final dayExercises = byDay[currentDay]!;
    final isFirstPage = i == 0;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                if (isFirstPage) ...[
                  _buildHeader(details, athlete, logo, boldFont, regularFont),
                  pw.SizedBox(height: 28),
                ],
                //day with exercises
                _buildDayCard(
                  currentDay,
                  dayExercises,
                  boldFont,
                  regularFont,
                  imageCache,
                  muscle,
                ),
                pw.Spacer(),
                pw.Divider(
                  color: _darkGrey,
                  thickness: 0.5,
                  indent: 0.0,
                  endIndent: 0.0,
                ),
                _buildFooter(boldFont, regularFont, instagram, phone),
              ],
            ),
          );
        },
      ),
    );

    // Yield to the event loop between pages so, on Web, the UI (loading
    // animation) keeps repainting instead of appearing frozen. On native
    // platforms this function runs inside a background isolate via
    // compute(), so `shouldYield` is false and this is skipped entirely —
    // there's no UI thread to protect in there.
    if (input.shouldYield) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  // add notes page if it is not empty
  final notes = details.program.notes?.trim();
  if (notes != null && notes.isNotEmpty) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        build: (context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _buildNotesPage(notes, boldFont, regularFont),
                pw.Spacer(),
                pw.Divider(
                  color: _darkGrey,
                  thickness: 0.5,
                  indent: 0.0,
                  endIndent: 0.0,
                ),
                _buildFooter(boldFont, regularFont, instagram, phone),
              ],
            ),
          );
        },
      ),
    );

    if (input.shouldYield) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  // NOTE ON doc.save(): this is a single synchronous, CPU-bound call inside
  // the `pdf` package (PDF object graph serialization). The package exposes
  // no async/chunking hook for it, so it cannot be split further without
  // forking the package. On Web this final call can still cause a short
  // freeze even with everything above chunked — yielding once more right
  // before it at least lets the UI paint its latest frame before that
  // happens.
  if (input.shouldYield) {
    await Future<void>.delayed(Duration.zero);
  }

  return doc.save();
}

// -------------------------------------------------------------------
// Image prefetch
// -------------------------------------------------------------------
Future<Map<String, pw.MemoryImage>> _prefetchExerciseImages(
  List<ProgramExerciseDetails> exercises,
) async {
  final cache = <String, pw.MemoryImage>{};
  //final seen = <String>{};

  // for (final block in exercises) {
  //   for (final itemDetails in block.items) {
  //     final exercise = itemDetails.exercise;
  //     final url = exercise.imageUrl;

  //     if (url == null || url.isEmpty || seen.contains(exercise.id)) {
  //       continue;
  //     }
  //     seen.add(exercise.id);

  //     try {
  //       final response = await http
  //           .get(Uri.parse(url))
  //           .timeout(const Duration(seconds: 5));

  //       if (response.statusCode == 200) {
  //         cache[exercise.id] = pw.MemoryImage(response.bodyBytes);
  //       }
  //     } catch (_) {
  //       // تصویر در دسترس نبود
  //     }
  //   }
  // }

  return cache;
}

// -------------------------------------------------------------------
// Header
// -------------------------------------------------------------------
pw.Widget _buildHeader(
  WorkoutProgramDetails details,
  AthleteInfo athlete,
  pw.MemoryImage logo,
  pw.Font boldFont,
  pw.Font regularFont,
) {
  final program = details.program;
  final dateStr = _convertToPersianDate(athlete.date);

  return pw.Container(
    height: 60,
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Expanded(
          flex: 4,
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                _headerStatCell(
                  'نام و نام خانوادگی',
                  athlete.fullName,
                  boldFont,
                  regularFont,
                  pw.BorderRadius.only(
                    topRight: pw.Radius.circular(4),
                    bottomRight: pw.Radius.circular(4),
                  ),
                ),
                _headerStatCell(
                  'وزن',
                  athlete.weight,
                  boldFont,
                  regularFont,
                  pw.BorderRadius.zero,
                ),
                _headerStatCell(
                  'قد',
                  athlete.height,
                  boldFont,
                  regularFont,
                  pw.BorderRadius.zero,
                ),
                _headerStatCell(
                  'تاریخ',
                  dateStr,
                  boldFont,
                  regularFont,
                  pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(4),
                    bottomLeft: pw.Radius.circular(4),
                  ),
                ),

                pw.SizedBox(width: 8),

                _headerStatCell(
                  'سطح برنامه',
                  program.level.label,
                  boldFont,
                  regularFont,
                  pw.BorderRadius.only(
                    topRight: pw.Radius.circular(4),
                    bottomRight: pw.Radius.circular(4),
                  ),
                ),
                _headerStatCell(
                  'هدف برنامه',
                  program.goal.label,
                  boldFont,
                  regularFont,
                  pw.BorderRadius.zero,
                ),
                _headerStatCell(
                  'تعداد روز در هفته',
                  '${program.daysPerWeek} روز',
                  boldFont,
                  regularFont,
                  pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(4),
                    bottomLeft: pw.Radius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),

        pw.SizedBox(width: 14),
        pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.SizedBox(height: 6),
            pw.Text(
              'KAREN',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: _black,
              ),
            ),
            pw.Text(
              'SPORT CLUB',
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 8,
                color: _black,
              ),
            ),
          ],
        ),
        pw.SizedBox(width: 4),
        pw.Container(
          decoration: pw.BoxDecoration(
            color: _black,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          width: 58,
          height: 58,
          child: pw.Image(logo),
        ),
      ],
    ),
  );
}

pw.Widget _headerStatCell(
  String label,
  String value,
  pw.Font boldFont,
  pw.Font regularFont,
  pw.BorderRadius radius,
) {
  return pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _darkGrey, width: 0.5),
        borderRadius: radius,
      ),
      alignment: pw.Alignment.center,
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(font: boldFont, fontSize: 7, color: _black),
          ),
          pw.Divider(color: _grey, thickness: 0.5, indent: 0, endIndent: 0),
          pw.Text(
            value,
            style: pw.TextStyle(font: regularFont, fontSize: 8, color: _black),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

// -------------------------------------------------------------------
// Day + Exercise Table
// -------------------------------------------------------------------
pw.Widget _buildDayCard(
  int day,
  List<ProgramExerciseDetails> dayExercises,
  pw.Font boldFont,
  pw.Font regularFont,
  Map<String, pw.MemoryImage> imageCache,
  pw.MemoryImage muscle,
) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _darkGrey, width: 0.5),
      borderRadius: pw.BorderRadius.circular(_cardRadius),
    ),
    child: pw.ClipRRect(
      horizontalRadius: _cardRadius,
      verticalRadius: _cardRadius,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          _buildDayBanner(day, regularFont),
          _buildTableHeaderRow(boldFont),
          ...dayExercises.asMap().entries.map((entry) {
            final number = entry.key + 1;
            final isLast = entry.key == dayExercises.length - 1;
            return _buildExerciseBlockRow(
              entry.value,
              number,
              boldFont,
              regularFont,
              imageCache,
              isLast,
              muscle,
            );
          }),
        ],
      ),
    ),
  );
}

pw.Widget _buildDayBanner(int day, pw.Font regularFont) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    color: _light,
    alignment: pw.Alignment.center,
    child: pw.Text(
      'شماره روز : $day',
      style: pw.TextStyle(font: regularFont, color: _black, fontSize: 8),
    ),
  );
}

pw.Widget _buildTableHeaderRow(pw.Font boldFont) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: _light,
      border: pw.Border(
        top: pw.BorderSide(color: _darkGrey, width: 0.5),
        bottom: pw.BorderSide(color: _darkGrey, width: 0.5),
      ),
    ),
    height: 28,
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _headerCell('شماره', _numberFlex, boldFont),
        //_headerCell('تصویر', _imageFlex, boldFont),
        _headerCell('تمرین', _nameFlex, boldFont),
        _headerCell('ست', _setsFlex, boldFont),
        _headerCell('تکرارها', _repsFlex, boldFont),
        _headerCell('تمپو', _tempoFlex, boldFont),
        _headerCell('استراحت', _restFlex, boldFont),
        _headerCell('سیستم', _systemFlex, boldFont),
      ],
    ),
  );
}

pw.Widget _headerCell(String text, int flex, pw.Font boldFont) {
  return pw.Expanded(
    flex: flex,
    child: pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: boldFont, fontSize: 8, color: _black),
      ),
    ),
  );
}

pw.Widget _buildExerciseBlockRow(
  ProgramExerciseDetails block,
  int number,
  pw.Font boldFont,
  pw.Font regularFont,
  Map<String, pw.MemoryImage> imageCache,
  bool isLast,
  pw.MemoryImage muscle,
) {
  final pe = block.programExercise;
  final isSuperSet = pe.trainingSystem == TrainingSystem.superSet;

  final exerciseNames = block.items
      .map((itemDetails) => itemDetails.exercise.name)
      .toList();

  final primaryExercise = block.items.isNotEmpty
      ? block.items.first.exercise
      : null;

  final itemCount = block.items.length;
  final totalHeight = itemCount > 1 ? _subRowHeight * itemCount : _rowHeight;

  if (isSuperSet && itemCount == 2) {
    // superset with 2 items
    return _buildSuperSetRow(
      block,
      number,
      boldFont,
      regularFont,
      imageCache,
      isLast,
      primaryExercise,
      exerciseNames,
      muscle,
    );
  } else {
    return _buildNormalRow(
      block,
      number,
      boldFont,
      regularFont,
      imageCache,
      isLast,
      primaryExercise,
      exerciseNames,
      itemCount,
      totalHeight,
      muscle,
    );
  }
}

pw.Widget _exerciseNameWithDescription(
  ProgramExerciseItem item,
  Exercise exercise,
  pw.Font boldFont,
  pw.Font regularFont,
) {
  final description = item.description?.trim();

  return pw.RichText(
    textAlign: pw.TextAlign.center,
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text: exercise.name,
          style: pw.TextStyle(font: boldFont, fontSize: 9, color: _black),
        ),
        if (description != null && description.isNotEmpty)
          pw.TextSpan(
            text: '  $description',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 7,
              color: PdfColors.grey600,
            ),
          ),
      ],
    ),
  );
}

// normal row
pw.Widget _buildNormalRow(
  ProgramExerciseDetails block,
  int number,
  pw.Font boldFont,
  pw.Font regularFont,
  Map<String, pw.MemoryImage> imageCache,
  bool isLast,
  Exercise? primaryExercise,
  List<String> exerciseNames,
  int itemCount,
  double totalHeight,
  pw.MemoryImage muscle,
) {
  final pe = block.programExercise;
  final rightColumnChildren = <pw.Widget>[];

  for (var i = 0; i < block.items.length; i++) {
    final itemDetails = block.items[i];
    final item = itemDetails.item;
    final isLastItem = i == block.items.length - 1;

    rightColumnChildren.add(
      pw.Container(
        height: itemCount > 1 ? _subRowHeight : _rowHeight,
        decoration: pw.BoxDecoration(
          border: isLastItem
              ? null
              : pw.Border(bottom: pw.BorderSide(color: _darkGrey, width: 0.3)),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _subCell(_repsFlex, item.reps, regularFont),
            _subCell(_tempoFlex, item.tempo, regularFont),
            _subCell(_restFlex, pe.rest, regularFont),
            _subCell(_systemFlex, '-', regularFont),
          ],
        ),
      ),
    );
  }

  //number
  return pw.Container(
    height: totalHeight,
    decoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: isLast
            ? pw.BorderSide.none
            : pw.BorderSide(color: _darkGrey, width: 0.5),
      ),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // number
        pw.Expanded(
          flex: _numberFlex,
          child: pw.Container(
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.all(2),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: _darkGrey, width: 0.5),
              ),
            ),
            child: pw.Text(
              '$number',
              style: pw.TextStyle(font: boldFont, fontSize: 11, color: _orange),
            ),
          ),
        ),

        // image
        // pw.Expanded(
        //   flex: _imageFlex,
        //   child: pw.Container(
        //     alignment: pw.Alignment.center,
        //     padding: const pw.EdgeInsets.symmetric(vertical: 4),
        //     decoration: pw.BoxDecoration(
        //       border: pw.Border(
        //         left: pw.BorderSide(color: _darkGrey, width: 0.5),
        //       ),
        //     ),
        //     child: pw.Image(
        //       muscle,
        //       width: 15,
        //     ), //_exerciseThumbnail(primaryExercise, imageCache, muscle),
        //   ),
        // ),
        // name
        // pw.Expanded(
        //   flex: _nameFlex,
        //   child: pw.Container(
        //     alignment: pw.Alignment.center,
        //     padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        //     decoration: pw.BoxDecoration(
        //       border: pw.Border(
        //         left: pw.BorderSide(color: _darkGrey, width: 0.5),
        //       ),
        //     ),
        //     child: pw.Text(
        //       exerciseNames.join(' + '),
        //       textAlign: pw.TextAlign.center,
        //       style: pw.TextStyle(font: boldFont, fontSize: 9),
        //     ),
        //   ),
        // ),

        // name + description
        pw.Expanded(
          flex: _nameFlex,
          child: pw.Container(
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: _darkGrey, width: 0.5),
              ),
            ),
            child: block.items.length == 1
                ? _exerciseNameWithDescription(
                    block.items.first.item,
                    block.items.first.exercise,
                    boldFont,
                    regularFont,
                  )
                : pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < block.items.length; i++) ...[
                        if (i > 0)
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            child: pw.Text(
                              '+',
                              style: pw.TextStyle(
                                font: regularFont,
                                fontSize: 7,
                                color: _darkGrey,
                              ),
                            ),
                          ),
                        _exerciseNameWithDescription(
                          block.items[i].item,
                          block.items[i].exercise,
                          boldFont,
                          regularFont,
                        ),
                      ],
                    ],
                  ),
          ),
        ),

        // set
        pw.Expanded(
          flex: _setsFlex,
          child: pw.Container(
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: _darkGrey, width: 0.5),
              ),
            ),
            child: pw.Text(
              pe.sets,
              style: pw.TextStyle(font: boldFont, fontSize: 10),
            ),
          ),
        ),
        // right columns
        pw.Expanded(
          flex: _repsFlex + _tempoFlex + _restFlex + _systemFlex,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: rightColumnChildren,
          ),
        ),
      ],
    ),
  );
}

// superset row
pw.Widget _buildSuperSetRow(
  ProgramExerciseDetails block,
  int number,
  pw.Font boldFont,
  pw.Font regularFont,
  Map<String, pw.MemoryImage> imageCache,
  bool isLast,
  Exercise? primaryExercise,
  List<String> exerciseNames,
  pw.MemoryImage muscle,
) {
  final pe = block.programExercise;
  final item1 = block.items[0].item;
  final item2 = block.items[1].item;

  // whole row height
  final totalHeight = _subRowHeight * 2;

  return pw.Container(
    height: totalHeight,
    decoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: isLast
            ? pw.BorderSide.none
            : pw.BorderSide(color: _darkGrey, width: 0.5),
      ),
    ),

    //number
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // number
        pw.Expanded(
          flex: _numberFlex,
          child: pw.Container(
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.all(2),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: _darkGrey, width: 0.5),
              ),
            ),
            child: pw.Text(
              '$number',
              style: pw.TextStyle(font: boldFont, fontSize: 11, color: _orange),
            ),
          ),
        ),
        // image
        // pw.Expanded(
        //   flex: _imageFlex,
        //   child: pw.Container(
        //     alignment: pw.Alignment.center,
        //     padding: const pw.EdgeInsets.symmetric(vertical: 4),
        //     decoration: pw.BoxDecoration(
        //       border: pw.Border(
        //         left: pw.BorderSide(color: _darkGrey, width: 0.5),
        //       ),
        //     ),
        //     child: pw.Image(
        //       muscle,
        //       width: 15,
        //     ), //_exerciseThumbnail(primaryExercise, imageCache, muscle),
        //   ),
        // ),
        // name with 2 rows
        // pw.Expanded(
        //   flex: _nameFlex,
        //   child: pw.Container(
        //     alignment: pw.Alignment.center,
        //     padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        //     decoration: pw.BoxDecoration(
        //       border: pw.Border(
        //         left: pw.BorderSide(color: _darkGrey, width: 0.5),
        //       ),
        //     ),
        //     child: pw.Column(
        //       mainAxisAlignment: pw.MainAxisAlignment.center,
        //       children: [
        //         pw.Text(
        //           exerciseNames[0],
        //           textAlign: pw.TextAlign.center,
        //           style: pw.TextStyle(font: boldFont, fontSize: 9),
        //         ),
        //         pw.SizedBox(height: 4),
        //         pw.Text('+'),
        //         pw.SizedBox(height: 4),
        //         pw.Text(
        //           exerciseNames[1],
        //           textAlign: pw.TextAlign.center,
        //           style: pw.TextStyle(font: boldFont, fontSize: 9),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),

        // name with 2 rows
        pw.Expanded(
          flex: _nameFlex,
          child: pw.Container(
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: _darkGrey, width: 0.5),
              ),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // First exercise
                _exerciseNameWithDescription(
                  block.items[0].item,
                  block.items[0].exercise,
                  boldFont,
                  regularFont,
                ),

                // +
                pw.SizedBox(height: 3),
                pw.Text('+', style: pw.TextStyle(font: boldFont, fontSize: 7)),
                pw.SizedBox(height: 3),

                // Second exercise
                _exerciseNameWithDescription(
                  block.items[1].item,
                  block.items[1].exercise,
                  boldFont,
                  regularFont,
                ),
              ],
            ),
          ),
        ),
        // set
        pw.Expanded(
          flex: _setsFlex,
          child: pw.Container(
            alignment: pw.Alignment.center,
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                left: pw.BorderSide(color: _darkGrey, width: 0.5),
              ),
            ),
            child: pw.Text(
              pe.sets,
              style: pw.TextStyle(font: boldFont, fontSize: 10),
            ),
          ),
        ),
        // right column with 1 row
        pw.Expanded(
          flex: _repsFlex + _tempoFlex + _restFlex + _systemFlex,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 2 rows
              pw.Expanded(
                flex: _repsFlex + _tempoFlex,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    // reps first
                    pw.Container(
                      height: _subRowHeight,
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          bottom: pw.BorderSide(color: _darkGrey, width: 0.3),
                          left: pw.BorderSide(color: _darkGrey, width: 0.5),
                        ),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          _subCell(_repsFlex, item1.reps, regularFont),
                          _subCell(_tempoFlex, item1.tempo, regularFont),
                        ],
                      ),
                    ),
                    // reps second
                    pw.Container(
                      height: _subRowHeight,
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          left: pw.BorderSide(color: _darkGrey, width: 0.5),
                        ),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                        children: [
                          _subCell(_repsFlex, item2.reps, regularFont),
                          _subCell(_tempoFlex, item2.tempo, regularFont),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // rest
              pw.Expanded(
                flex: _restFlex,
                child: pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: _darkGrey, width: 0.5),
                    ),
                  ),
                  child: pw.Text(
                    pe.rest,
                    style: pw.TextStyle(font: regularFont, fontSize: 9),
                  ),
                ),
              ),
              // system
              pw.Expanded(
                flex: _systemFlex,
                child: pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      left: pw.BorderSide(color: _darkGrey, width: 0.5),
                    ),
                  ),
                  child: pw.Text(
                    'سوپرست',
                    style: pw.TextStyle(font: regularFont, fontSize: 9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _subCell(int flex, String text, pw.Font regularFont) {
  return pw.Expanded(
    flex: flex,
    child: pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: _darkGrey, width: 0.5)),
      ),
      child: pw.Text(
        text.isEmpty ? '-' : text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: regularFont, fontSize: 8),
      ),
    ),
  );
}

// -------------------------------------------------------------------
// Notes page
// -------------------------------------------------------------------
pw.Widget _buildNotesPage(String notes, pw.Font boldFont, pw.Font regularFont) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _darkGrey, width: 0.5),
      borderRadius: pw.BorderRadius.circular(_cardRadius),
    ),
    child: pw.ClipRRect(
      horizontalRadius: _cardRadius,
      verticalRadius: _cardRadius,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // عنوان
          pw.Container(
            decoration: pw.BoxDecoration(
              color: _light,
              border: pw.Border(
                bottom: pw.BorderSide(color: _darkGrey, width: 0.5),
              ),
            ),
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'توضیحات',
              style: pw.TextStyle(font: boldFont, color: _black, fontSize: 11),
            ),
          ),

          // desc
          pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Text(
              notes,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: regularFont,
                color: _black,
                fontSize: 10,
                lineSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// -------------------------------------------------------------------
// Footer
// -------------------------------------------------------------------
pw.Widget _buildFooter(
  pw.Font boldFont,
  pw.Font regularFont,
  pw.MemoryImage instagramIcon,
  pw.MemoryImage phoneIcon,
) {
  return pw.Container(
    height: 30,
    padding: const pw.EdgeInsets.symmetric(horizontal: 10),
    decoration: pw.BoxDecoration(
      //border: pw.Border(top: pw.BorderSide(color: _darkGrey, width: 0.5)),
      border: pw.Border.all(color: _darkGrey, width: 0.5),
      borderRadius: pw.BorderRadius.circular(12),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              ClubInfo.phone,
              style: pw.TextStyle(font: boldFont, fontSize: 11, color: _black),
            ),
            pw.SizedBox(width: 2),
            pw.Container(width: 16, height: 16, child: pw.Image(phoneIcon)),
          ],
        ),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              ClubInfo.instagram,
              style: pw.TextStyle(font: boldFont, fontSize: 11, color: _black),
            ),
            pw.SizedBox(width: 2),
            pw.Container(width: 17, height: 17, child: pw.Image(instagramIcon)),
          ],
        ),
      ],
    ),
  );
}

String _convertToPersianDate(DateTime date) {
  try {
    final jalali = Jalali.fromDateTime(date);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
  } catch (e) {
    // returns with no convertion
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}

// pw.Widget _numberBadge(int number, pw.Font boldFont) {
//   return pw.Container(
//     width: 20,
//     height: 20,
//     alignment: pw.Alignment.center,
//     decoration: pw.BoxDecoration(
//       color: _black,
//       borderRadius: pw.BorderRadius.circular(4),
//     ),
//     child: pw.Text(
//       '$number',
//       style: pw.TextStyle(font: boldFont, fontSize: 11, color: _orange),
//     ),
//   );
// }

// pw.Widget _exerciseThumbnail(
//   Exercise? exercise,
//   Map<String, pw.MemoryImage> imageCache,
//   pw.MemoryImage muxcle,
// ) {
//   if (exercise == null) return pw.SizedBox();

//   final image = imageCache[exercise.id];

//   if (image != null) {
//     return pw.SizedBox(
//       height: 30,
//       child: pw.Image(image, fit: pw.BoxFit.contain),
//     );
//   }

//   return pw.SizedBox();

//   // return pw.Container(
//   //   height: 30,
//   //   alignment: pw.Alignment.center,
//   //   child: pw.Text(
//   //     exercise.targetMuscle,
//   //     textAlign: pw.TextAlign.center,
//   //     style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey500),
//   //   ),
//   // );
// }
