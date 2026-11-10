// lib/features/workout_programs/data/services/pdf_generation/pdf_document_builder.dart
//
// Pure PDF-building logic. No dependency on Flutter bindings (no rootBundle,
// no BuildContext), so buildPdfDocument() is safe to run inside a background
// isolate via compute() on native platforms. On Flutter Web the same function
// runs on the main thread and yields to the event loop between pages when
// `input.shouldYield` is true.
//
// Pipeline:
//   1. MEASURE  - every exercise row is laid out once in a throw-away
//                 document to learn its natural height (content-driven).
//   2. PAGINATE - rows are distributed over pages using those heights.
//   3. RENDER   - each page is a normal pw.Page holding one rounded day card
//                 (banner + column header + rows), plus the fixed footer.
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:coach_studio/core/constants/club_info.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/athlete_info.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_item.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_details.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import 'pdf_build_input.dart';

// ─────────────────────────────────────────────────────────────────────────
// Layout constants
// ─────────────────────────────────────────────────────────────────────────

// Column width ratios.
const _numberFlex = 1;
const _nameFlex = 7;
const _setsFlex = 1;
const _repsFlex = 3;
const _tempoFlex = 2;
const _restFlex = 2;
const _systemFlex = 2;

// Colors.
const _black = PdfColor.fromInt(0xFF2B2B2B);
const _orange = PdfColor.fromInt(0xFFf88709);
const _light = PdfColor.fromInt(0xFFfef4ea);
const _grey = PdfColor.fromInt(0xFFE8E8E8);
const _darkGrey = PdfColors.grey300;

const _edge = pw.BorderSide(color: _darkGrey, width: 0.5);

// Minimum row heights (rows grow with their content beyond these).
const double _rowMinHeight = 36.0;
const double _subRowMinHeight = 32.0;
const double _tableHeaderHeight = 28.0;

// Thin separators.
const double _rowSeparator = 0.5; // between exercise rows
const double _lineGap = 0.3; // between the two lines of a superset

// Card corner radius.
const double _cardRadius = 4.0;

// Page geometry.
const double _pageMarginH = 20;
const double _pageMarginV = 28;
const double _footerReserve = 40; // divider + footer (30) + breathing room
const double _bannerHeightEstimate = 22;
const double _programHeaderBlock = 60 + 28; // header + gap (first page only)
const double _capacitySafety = 8;

// Height of the throw-away page used for measuring (never rendered).
const double _measurePageHeight = 100000;

// ─────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────

Future<Uint8List> buildPdfDocument(PdfBuildInput input) async {
  final details = input.details;
  final athlete = input.athlete;

  final fonts = _Fonts(
    regular: pw.Font.ttf(input.regularFontData),
    bold: pw.Font.ttf(input.boldFontData),
  );
  final logo = pw.MemoryImage(input.logoData.buffer.asUint8List());
  final instagram = pw.MemoryImage(input.instagramData.buffer.asUint8List());
  final phone = pw.MemoryImage(input.phoneData.buffer.asUint8List());

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: fonts.regular, bold: fonts.bold),
  );

  // 1. Group + number rows, then measure them all in one go.
  final byDay = _groupByDay(details.exercises);
  final days = byDay.keys.toList()..sort();

  final rowsByDay = <int, List<_RowSpec>>{
    for (final day in days)
      day: [
        for (var i = 0; i < byDay[day]!.length; i++)
          _RowSpec(block: byDay[day]![i], number: i + 1),
      ],
  };

  await _measureRows(rowsByDay.values.expand((r) => r).toList(), input);
  await _yieldIfNeeded(input);

  // 2 + 3. Paginate each day and render one page per segment.
  for (var i = 0; i < days.length; i++) {
    final day = days[i];
    final pages = _paginateDay(rowsByDay[day]!, firstDayOfProgram: i == 0);

    for (var p = 0; p < pages.length; p++) {
      doc.addPage(
        _buildDayPage(
          day: day,
          rows: pages[p],
          showProgramHeader: i == 0 && p == 0,
          details: details,
          athlete: athlete,
          logo: logo,
          instagram: instagram,
          phone: phone,
          fonts: fonts,
        ),
      );
      await _yieldIfNeeded(input);
    }
  }

  final notes = details.program.notes?.trim();
  if (notes != null && notes.isNotEmpty) {
    doc.addPage(
      _buildNotesPage(
        notes: notes,
        fonts: fonts,
        instagram: instagram,
        phone: phone,
      ),
    );
    await _yieldIfNeeded(input);
  }

  // doc.save() is one synchronous, CPU-bound call inside the `pdf` package
  // and cannot be chunked. Yielding right before it lets the UI paint its
  // latest frame before a possible short freeze on Web.
  await _yieldIfNeeded(input);

  return doc.save();
}

/// Lets the event loop run so the loading animation keeps repainting on Web.
/// On native platforms `shouldYield` is false (work runs in an isolate).
Future<void> _yieldIfNeeded(PdfBuildInput input) async {
  if (input.shouldYield) {
    await Future<void>.delayed(Duration.zero);
  }
}

Map<int, List<ProgramExerciseDetails>> _groupByDay(
  List<ProgramExerciseDetails> exercises,
) {
  final byDay = <int, List<ProgramExerciseDetails>>{};
  for (final e in exercises) {
    byDay.putIfAbsent(e.programExercise.day, () => []).add(e);
  }
  for (final list in byDay.values) {
    list.sort(
      (a, b) => a.programExercise.order.compareTo(b.programExercise.order),
    );
  }
  return byDay;
}

pw.Widget _rtl(pw.Widget child) =>
    pw.Directionality(textDirection: pw.TextDirection.rtl, child: child);

class _Fonts {
  const _Fonts({required this.regular, required this.bold});
  final pw.Font regular;
  final pw.Font bold;
}

// ─────────────────────────────────────────────────────────────────────────
// Row model
// ─────────────────────────────────────────────────────────────────────────

/// One table cell: [flex] is its column width ratio.
class _Cell {
  const _Cell(
    this.flex,
    this.child, {
    this.padding = const pw.EdgeInsets.symmetric(vertical: 4),
  });

  final int flex;
  final pw.Widget child;
  final pw.EdgeInsets padding;
}

/// One visual line of a row. A normal exercise is a single line; a superset
/// is two lines (one per exercise) sharing the number/rest/system cells.
class _Line {
  const _Line({
    required this.cells,
    required this.minHeight,
    this.lead = 0,
    this.trail = 0,
  });

  final List<_Cell> cells;
  final double minHeight;

  /// Flex units of the outer cells to the right (lead) / left (trail) of
  /// this line's cells. Only used by superset lines, so a line is measured at
  /// the same width it will have when rendered.
  final int lead;
  final int trail;
}

bool _isSuperSet(ProgramExerciseDetails block) =>
    block.programExercise.trainingSystem == TrainingSystem.superSet &&
    block.items.length == 2;

/// An exercise block with its number and (after measuring) line heights.
class _RowSpec {
  _RowSpec({required this.block, required this.number});

  final ProgramExerciseDetails block;
  final int number;
  List<double> heights = const [];

  bool get isSuperSet => _isSuperSet(block);

  double get height {
    if (heights.isEmpty) {
      return isSuperSet ? _subRowMinHeight * 2 + _lineGap : _rowMinHeight;
    }
    if (!isSuperSet) return heights.first;
    // heights = [name cell, reps line 1, reps line 2]
    return math.max(heights[0], heights[1] + heights[2] + _lineGap);
  }
}

List<_Line> _linesOf(_RowSpec spec, _Fonts f) {
  final block = spec.block;
  final pe = block.programExercise;

  if (spec.isSuperSet) {
    const repsPadding = pw.EdgeInsets.symmetric(horizontal: 2, vertical: 4);

    return [
      // Line 0: the single merged name cell (first + second exercise).
      _Line(
        minHeight: _subRowMinHeight * 2,
        lead: _numberFlex,
        trail: _setsFlex + _repsFlex + _tempoFlex + _restFlex + _systemFlex,
        cells: [
          _Cell(
            _nameFlex,
            _superSetNames(block.items[0], block.items[1], f),
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          ),
        ],
      ),
      // Lines 1-2: reps + tempo, one line per exercise.
      for (var i = 0; i < 2; i++)
        _Line(
          minHeight: _subRowMinHeight,
          lead: _numberFlex + _nameFlex + _setsFlex,
          trail: _restFlex + _systemFlex,
          cells: [
            _Cell(
              _repsFlex,
              _smallText(_formatReps(block.items[i].item), f),
              padding: repsPadding,
            ),
            _Cell(
              _tempoFlex,
              _smallText(block.items[i].item.tempo, f),
              padding: repsPadding,
            ),
          ],
        ),
    ];
  }

  // Normal block: the backend guarantees exactly one item.
  final item = block.items.first;
  const smallPadding = pw.EdgeInsets.symmetric(horizontal: 2, vertical: 4);
  return [
    _Line(
      minHeight: _rowMinHeight,
      cells: [
        _numberCell(spec.number, f),
        _Cell(
          _nameFlex,
          _nameText(item, f),
          padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        ),
        _Cell(_setsFlex, _setsText(pe.sets, f)),
        _Cell(
          _repsFlex,
          _smallText(_formatReps(item.item), f),
          padding: smallPadding,
        ),
        _Cell(
          _tempoFlex,
          _smallText(item.item.tempo, f),
          padding: smallPadding,
        ),
        _Cell(_restFlex, _smallText(pe.rest, f), padding: smallPadding),
        _Cell(_systemFlex, _smallText('-', f), padding: smallPadding),
      ],
    ),
  ];
}

// ── Cell contents ────────────────────────────────────────────────────────

_Cell _numberCell(int number, _Fonts f) => _Cell(
  _numberFlex,
  pw.Text(
    number.persianNumber,
    style: pw.TextStyle(font: f.bold, fontSize: 11, color: _orange),
  ),
  padding: const pw.EdgeInsets.all(2),
);

pw.Widget _setsText(String sets, _Fonts f) => pw.Text(
  sets.persianNumber,
  style: pw.TextStyle(font: f.bold, fontSize: 10),
);

pw.Widget _smallText(String text, _Fonts f) => pw.Text(
  text.isEmpty ? '-' : text.persianNumber,
  textAlign: pw.TextAlign.center,
  style: pw.TextStyle(font: f.regular, fontSize: 8),
);

pw.Widget _nameText(
  ProgramExerciseItemDetails details,
  _Fonts f, {
  bool plusPrefix = false,
}) {
  final description = details.item.description?.trim();

  return pw.RichText(
    textAlign: pw.TextAlign.center,
    text: pw.TextSpan(
      children: [
        if (plusPrefix)
          pw.TextSpan(
            text: '+  ',
            style: pw.TextStyle(
              font: f.bold,
              fontSize: 9,
              color: PdfColors.grey600,
            ),
          ),
        pw.TextSpan(
          text: details.exercise.name,
          style: pw.TextStyle(font: f.bold, fontSize: 9, color: _black),
        ),
        if (description != null && description.isNotEmpty)
          pw.TextSpan(
            text: '  $description',
            style: pw.TextStyle(
              font: f.regular,
              fontSize: 7,
              color: PdfColors.grey600,
            ),
          ),
      ],
    ),
  );
}

/// First exercise, a centered "+", then the second exercise.
pw.Widget _superSetNames(
  ProgramExerciseItemDetails first,
  ProgramExerciseItemDetails second,
  _Fonts f,
) {
  return pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      _nameText(first, f),
      pw.SizedBox(height: 3),
      pw.Text('+', style: pw.TextStyle(font: f.bold, fontSize: 8)),
      pw.SizedBox(height: 3),
      _nameText(second, f),
    ],
  );
}

/// reps are stored in set order; the PDF is RTL so they are shown reversed.
String _formatReps(ProgramExerciseItem item) => item.reps.reversed.join(' - ');

// ─────────────────────────────────────────────────────────────────────────
// 1. Measuring
// ─────────────────────────────────────────────────────────────────────────

/// Fills [RowSpec.heights] with each line's natural height (never below its
/// minimum). The probes use the same fonts, padding and column widths as the
/// final rows, but no alignment, so every cell shrinks to its content.
Future<void> _measureRows(List<_RowSpec> specs, PdfBuildInput input) async {
  if (specs.isEmpty) return;

  // Separate font instances: the measuring document is throw-away.
  final f = _Fonts(
    regular: pw.Font.ttf(input.regularFontData),
    bold: pw.Font.ttf(input.boldFontData),
  );

  final lines = [for (final s in specs) _linesOf(s, f)];
  final probes = [
    for (final rowLines in lines) [for (final l in rowLines) _probe(l)],
  ];

  final measureDoc = pw.Document(
    theme: pw.ThemeData.withFont(base: f.regular, bold: f.bold),
  );
  measureDoc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat(PdfPageFormat.a4.width, _measurePageHeight),
      margin: const pw.EdgeInsets.symmetric(horizontal: _pageMarginH),
      build: (_) => _rtl(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [for (final rowProbes in probes) ...rowProbes],
        ),
      ),
    ),
  );
  // Forces layout, so every probe has its final box.
  await measureDoc.save();

  for (var i = 0; i < specs.length; i++) {
    specs[i].heights = [
      for (var j = 0; j < lines[i].length; j++)
        math.max(probes[i][j].box?.height ?? 0, lines[i][j].minHeight) + 1,
    ];
  }
}

pw.Row _probe(_Line line) {
  final innerFlex = line.cells.fold<int>(0, (sum, c) => sum + c.flex);

  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (line.lead > 0) pw.Expanded(flex: line.lead, child: pw.SizedBox()),
      pw.Expanded(
        flex: innerFlex,
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (final c in line.cells)
              pw.Expanded(
                flex: c.flex,
                child: pw.Container(
                  padding: c.padding,
                  decoration: const pw.BoxDecoration(
                    border: pw.Border(left: _edge),
                  ),
                  child: c.child,
                ),
              ),
          ],
        ),
      ),
      if (line.trail > 0) pw.Expanded(flex: line.trail, child: pw.SizedBox()),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────
// 2. Pagination
// ─────────────────────────────────────────────────────────────────────────

double _bodyCapacity({required bool withProgramHeader}) =>
    PdfPageFormat.a4.height -
    2 * _pageMarginV -
    _footerReserve -
    (withProgramHeader ? _programHeaderBlock : 0) -
    _bannerHeightEstimate -
    _tableHeaderHeight -
    2 - // card border
    _capacitySafety;

/// Splits a day's rows into page-sized groups. A row is never split; a row
/// taller than a whole page is still placed on its own page.
List<List<_RowSpec>> _paginateDay(
  List<_RowSpec> rows, {
  required bool firstDayOfProgram,
}) {
  final pages = <List<_RowSpec>>[];
  var current = <_RowSpec>[];
  var used = 0.0;
  var capacity = _bodyCapacity(withProgramHeader: firstDayOfProgram);

  for (final row in rows) {
    final needed = row.height + (current.isEmpty ? 0 : _rowSeparator);

    if (current.isNotEmpty && used + needed > capacity) {
      pages.add(current);
      current = <_RowSpec>[];
      used = 0;
      capacity = _bodyCapacity(withProgramHeader: false);
    }

    used += row.height + (current.isEmpty ? 0 : _rowSeparator);
    current.add(row);
  }

  if (current.isNotEmpty) pages.add(current);
  return pages;
}

// ─────────────────────────────────────────────────────────────────────────
// 3. Rendering
// ─────────────────────────────────────────────────────────────────────────

pw.Page _buildDayPage({
  required int day,
  required List<_RowSpec> rows,
  required bool showProgramHeader,
  required WorkoutProgramDetails details,
  required AthleteInfo athlete,
  required pw.MemoryImage logo,
  required pw.MemoryImage instagram,
  required pw.MemoryImage phone,
  required _Fonts fonts,
}) {
  return pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.symmetric(
      horizontal: _pageMarginH,
      vertical: _pageMarginV,
    ),
    build: (context) {
      return _rtl(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            if (showProgramHeader) ...[
              _buildHeader(details, athlete, logo, fonts),
              pw.SizedBox(height: 28),
            ],
            _buildDayCard(day, rows, fonts),
            pw.Spacer(),
            pw.Divider(
              color: _darkGrey,
              thickness: 0.5,
              indent: 0.0,
              endIndent: 0.0,
            ),
            _buildFooter(fonts, instagram, phone),
          ],
        ),
      );
    },
  );
}

/// One bordered, rounded card: banner + column header + this page's rows.
pw.Widget _buildDayCard(int day, List<_RowSpec> rows, _Fonts f) {
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
          _buildDayBanner(day, f),
          _buildTableHeaderRow(f),
          for (var i = 0; i < rows.length; i++) ...[
            _renderRow(rows[i], f),
            if (i < rows.length - 1)
              pw.Container(height: _rowSeparator, color: _darkGrey),
          ],
        ],
      ),
    ),
  );
}

pw.Widget _buildDayBanner(int day, _Fonts f) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(vertical: 4),
    color: _light,
    alignment: pw.Alignment.center,
    child: pw.Text(
      'شماره روز  :  ${day.persianNumber}',
      style: pw.TextStyle(font: f.regular, color: _black, fontSize: 8),
    ),
  );
}

pw.Widget _buildTableHeaderRow(_Fonts f) {
  pw.Widget cell(String text, int flex) => pw.Expanded(
    flex: flex,
    child: pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: f.bold, fontSize: 8, color: _black),
      ),
    ),
  );

  return pw.Container(
    decoration: const pw.BoxDecoration(
      color: _light,
      border: pw.Border(top: _edge, bottom: _edge),
    ),
    height: _tableHeaderHeight,
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        cell('شماره', _numberFlex),
        cell('تمرین', _nameFlex),
        cell('ست', _setsFlex),
        cell('تکرارها', _repsFlex),
        cell('تمپو', _tempoFlex),
        cell('(s) استراحت', _restFlex),
        cell('سیستم', _systemFlex),
      ],
    ),
  );
}

// ── Rows ─────────────────────────────────────────────────────────────────

/// A table cell with the thin separator line on its left side.
pw.Widget _boxed(_Cell c) => pw.Container(
  alignment: pw.Alignment.center,
  padding: c.padding,
  decoration: const pw.BoxDecoration(border: pw.Border(left: _edge)),
  child: c.child,
);

/// Cells laid out at an exact, already-measured height.
pw.Widget _renderCells(List<_Cell> cells, double height) {
  return pw.SizedBox(
    height: height,
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        for (final c in cells) pw.Expanded(flex: c.flex, child: _boxed(c)),
      ],
    ),
  );
}

pw.Widget _renderRow(_RowSpec spec, _Fonts f) {
  final lines = _linesOf(spec, f);

  if (!spec.isSuperSet) {
    return _renderCells(lines.first.cells, spec.height);
  }

  final pe = spec.block.programExercise;
  final total = spec.height;

  // Any extra height (long name/description) is shared by the two
  // reps lines so the thin divider stays centered.
  final extra = total - (spec.heights[1] + spec.heights[2] + _lineGap);
  final line1 = spec.heights[1] + extra / 2;
  final line2 = spec.heights[2] + extra / 2;

  return pw.SizedBox(
    height: total,
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Expanded(
          flex: _numberFlex,
          child: _boxed(_numberCell(spec.number, f)),
        ),
        pw.Expanded(flex: _nameFlex, child: _boxed(lines[0].cells.first)),
        pw.Expanded(
          flex: _setsFlex,
          child: _boxed(_Cell(_setsFlex, _setsText(pe.sets, f))),
        ),
        pw.Expanded(
          flex: _repsFlex + _tempoFlex,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              _renderCells(lines[1].cells, line1),
              pw.Container(height: _lineGap, color: _darkGrey),
              _renderCells(lines[2].cells, line2),
            ],
          ),
        ),
        pw.Expanded(
          flex: _restFlex,
          child: _boxed(
            _Cell(
              _restFlex,
              pw.Text(
                pe.rest.persianNumber,
                style: pw.TextStyle(font: f.regular, fontSize: 9),
              ),
            ),
          ),
        ),
        pw.Expanded(
          flex: _systemFlex,
          child: _boxed(
            _Cell(
              _systemFlex,
              pw.Text(
                'سوپرست',
                style: pw.TextStyle(font: f.regular, fontSize: 9),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Program header
// ─────────────────────────────────────────────────────────────────────────

pw.Widget _buildHeader(
  WorkoutProgramDetails details,
  AthleteInfo athlete,
  pw.MemoryImage logo,
  _Fonts f,
) {
  final program = details.program;
  final dateStr = _convertToPersianDate(athlete.date);

  pw.Widget cell(
    String label,
    String value,
    pw.BorderRadius radius, {
    int flex = 1,
  }) => _headerStatCell(label, value, f, radius, flex: flex);

  final rightEdge = pw.BorderRadius.only(
    topRight: pw.Radius.circular(4),
    bottomRight: pw.Radius.circular(4),
  );
  final leftEdge = pw.BorderRadius.only(
    topLeft: pw.Radius.circular(4),
    bottomLeft: pw.Radius.circular(4),
  );

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
                cell(
                  'نام و نام خانوادگی',
                  athlete.fullName,
                  rightEdge,
                  flex: 2,
                ),
                cell(
                  '(kg) وزن',
                  athlete.weight.persianNumber,
                  pw.BorderRadius.zero,
                ),
                cell(
                  '(cm) قد',
                  athlete.height.persianNumber,
                  pw.BorderRadius.zero,
                ),
                cell('تاریخ', dateStr.persianNumber, leftEdge),
                pw.SizedBox(width: 8),
                cell('سطح', program.level.label, rightEdge),
                cell('هدف', program.goal.label, pw.BorderRadius.zero),
                cell(
                  'روز در هفته',
                  '${program.daysPerWeek.persianNumber} روز',
                  leftEdge,
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
                font: f.bold,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: _black,
              ),
            ),
            pw.Text(
              'SPORT CLUB',
              style: pw.TextStyle(font: f.regular, fontSize: 8, color: _black),
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
  _Fonts f,
  pw.BorderRadius radius, {
  int flex = 1,
}) {
  return pw.Expanded(
    flex: flex,
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
            style: pw.TextStyle(font: f.bold, fontSize: 7, color: _black),
          ),
          pw.Divider(color: _grey, thickness: 0.5, indent: 0, endIndent: 0),
          pw.Text(
            value,
            style: pw.TextStyle(font: f.regular, fontSize: 8, color: _black),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Notes page
// ─────────────────────────────────────────────────────────────────────────

pw.Page _buildNotesPage({
  required String notes,
  required _Fonts fonts,
  required pw.MemoryImage instagram,
  required pw.MemoryImage phone,
}) {
  return pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.symmetric(
      horizontal: _pageMarginH,
      vertical: _pageMarginV,
    ),
    build: (context) {
      return _rtl(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _buildNotesCard(notes, fonts),
            pw.Spacer(),
            pw.Divider(
              color: _darkGrey,
              thickness: 0.5,
              indent: 0.0,
              endIndent: 0.0,
            ),
            _buildFooter(fonts, instagram, phone),
          ],
        ),
      );
    },
  );
}

pw.Widget _buildNotesCard(String notes, _Fonts f) {
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
          pw.Container(
            decoration: const pw.BoxDecoration(
              color: _light,
              border: pw.Border(bottom: _edge),
            ),
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            alignment: pw.Alignment.center,
            child: pw.Text(
              'توضیحات',
              style: pw.TextStyle(font: f.bold, color: _black, fontSize: 11),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Text(
              notes,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: f.regular,
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

// ─────────────────────────────────────────────────────────────────────────
// Footer
// ─────────────────────────────────────────────────────────────────────────

pw.Widget _buildFooter(
  _Fonts f,
  pw.MemoryImage instagramIcon,
  pw.MemoryImage phoneIcon,
) {
  pw.Widget item(String text, pw.MemoryImage icon, double iconSize) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          text,
          style: pw.TextStyle(font: f.bold, fontSize: 11, color: _black),
        ),
        pw.SizedBox(width: 2),
        pw.Container(width: iconSize, height: iconSize, child: pw.Image(icon)),
      ],
    );
  }

  return pw.Container(
    height: 30,
    padding: const pw.EdgeInsets.symmetric(horizontal: 10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _darkGrey, width: 0.5),
      borderRadius: pw.BorderRadius.circular(12),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        item(ClubInfo.phone, phoneIcon, 16),
        item(ClubInfo.instagram, instagramIcon, 17),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────

String _convertToPersianDate(DateTime date) {
  String format(int year, int month, int day) =>
      '$year/${month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';

  try {
    final jalali = Jalali.fromDateTime(date);
    return format(jalali.year, jalali.month, jalali.day);
  } catch (_) {
    // Falls back to the Gregorian date if conversion fails.
    return format(date.year, date.month, date.day);
  }
}
