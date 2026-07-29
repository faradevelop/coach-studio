// lib/features/workout_programs/data/services/workout_program_pdf_generator.dart
import 'dart:typed_data';

import 'package:coach_studio/core/constants/club_info.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/athlete_info.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_details.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shamsi_date/shamsi_date.dart';

class WorkoutProgramPdfGenerator {
  // نسبت عرض ستون‌ها
  static const _numberFlex = 1;
  static const _imageFlex = 2;
  static const _nameFlex = 5;
  static const _setsFlex = 1;
  static const _repsFlex = 3;
  static const _tempoFlex = 2;
  static const _restFlex = 2;
  static const _systemFlex = 2;

  static const _black = PdfColor.fromInt(0xFF2B2B2B);
  static const _orange = PdfColor.fromInt(0xFFf88709);
  static const _light = PdfColor.fromInt(0xFFfef4ea);
  static const _grey = PdfColor.fromInt(0xFFE8E8E8);
  static const _darkGrey = PdfColors.grey300;

  static const double _rowHeight = 36.0;
  static const double _subRowHeight = 32.0;

  // ✅ شعاع گردی کارت روز (باید هم روی Container بیرونی و هم روی ClipRRect یکسان باشد)
  static const double _cardRadius = 4.0;

  Future<Uint8List> generate({
    required WorkoutProgramDetails details,
    required AthleteInfo athlete,
  }) async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Vazirmatn-Bold.ttf'),
    );
    final logoBytes = await rootBundle.load(ClubInfo.logoAsset);
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    final instagramBytes = await rootBundle.load(ClubInfo.instagramAsset);
    final instagram = pw.MemoryImage(instagramBytes.buffer.asUint8List());
    final phoneBytes = await rootBundle.load(ClubInfo.phoneAsset);
    final phone = pw.MemoryImage(phoneBytes.buffer.asUint8List());

    final muscleBytes = await rootBundle.load(ClubInfo.muscleAsset);
    final muscle = pw.MemoryImage(muscleBytes.buffer.asUint8List());

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
      final day = days[i];
      final dayExercises = byDay[day]!;

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
                  if (i == 0) ...[
                    _buildHeader(details, athlete, logo, boldFont, regularFont),
                    pw.SizedBox(height: 28),
                  ],
                  // ✅ بنر روز + جدول در یک کارت واحد گردشده
                  _buildDayCard(
                    day,
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
    }

    // ✅ صفحه‌ی توضیحات — فقط در صورتی که notes خالی نباشد
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
                    _levelLabel(program.level),
                    boldFont,
                    regularFont,
                    pw.BorderRadius.only(
                      topRight: pw.Radius.circular(4),
                      bottomRight: pw.Radius.circular(4),
                    ),
                  ),
                  _headerStatCell(
                    'هدف برنامه',
                    _goalLabel(program.goal),
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
              style: pw.TextStyle(
                font: regularFont,
                fontSize: 8,
                color: _black,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------
  // ✅ کارت روز (بنر + جدول) — یک بلاک واحد که با ClipRRect گرد می‌شود
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

  // بنر روز — دیگر بوردر و radius مجزا ندارد چون داخل ClipRRect کارت است
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
          _headerCell('تصویر', _imageFlex, boldFont),
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

    // ✅ برای سوپرست: ستون‌های استراحت و سیستم باید یک بخشی باشند (ادغام شده)
    // برای این کار، یک ویجت جداگانه برای سمت راست می‌سازیم که در آن
    // ستون‌های استراحت و سیستم به صورت یک سلول بزرگ با دو ردیف نمایش داده می‌شوند

    if (isSuperSet && itemCount == 2) {
      // ✅ حالت سوپرست با 2 آیتم
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
      // ✅ حالت عادی (غیر سوپرست)
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

  // ✅ ردیف برای حالت عادی (غیر سوپرست)
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
                : pw.Border(
                    bottom: pw.BorderSide(color: _darkGrey, width: 0.3),
                  ),
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
          // شماره
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
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: _orange,
                ),
              ),
            ),
          ),
          // تصویر
          pw.Expanded(
            flex: _imageFlex,
            child: pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: _darkGrey, width: 0.5),
                ),
              ),
              child: pw.Image(
                muscle,
                width: 15,
              ), //_exerciseThumbnail(primaryExercise, imageCache, muscle),
            ),
          ),
          // نام تمرین
          pw.Expanded(
            flex: _nameFlex,
            child: pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 4,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: _darkGrey, width: 0.5),
                ),
              ),
              child: pw.Text(
                exerciseNames.join(' + '),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(font: boldFont, fontSize: 9),
              ),
            ),
          ),
          // ست
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
          // ستون‌های سمت راست
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

  // ✅ ردیف مخصوص سوپرست - ستون‌های استراحت و سیستم یک بخشی هستند
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

    // ارتفاع کل: دو ردیف
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
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // شماره (هم ارتفاع کل)
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
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: _orange,
                ),
              ),
            ),
          ),
          // تصویر (هم ارتفاع کل)
          pw.Expanded(
            flex: _imageFlex,
            child: pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: _darkGrey, width: 0.5),
                ),
              ),
              child: pw.Image(
                muscle,
                width: 15,
              ), //_exerciseThumbnail(primaryExercise, imageCache, muscle),
            ),
          ),
          // نام تمرین (دو ردیف)
          pw.Expanded(
            flex: _nameFlex,
            child: pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.symmetric(
                vertical: 4,
                horizontal: 4,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  left: pw.BorderSide(color: _darkGrey, width: 0.5),
                ),
              ),
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    exerciseNames[0],
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: boldFont, fontSize: 9),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text('+'),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    exerciseNames[1],
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(font: boldFont, fontSize: 9),
                  ),
                ],
              ),
            ),
          ),
          // ست (هم ارتفاع کل)
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
          // ✅ بخش سمت راست: تکرارها و تمپو در دو ردیف، استراحت و سیستم یک بخشی
          pw.Expanded(
            flex: _repsFlex + _tempoFlex + _restFlex + _systemFlex,
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // ستون تکرارها و تمپو (دو ردیف)
                pw.Expanded(
                  flex: _repsFlex + _tempoFlex,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      // ردیف اول: تکرارها
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
                      // ردیف دوم: تکرارها
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
                // ✅ ستون استراحت (یک بخشی - هم ارتفاع کل)
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
                // ✅ ستون سیستم (یک بخشی - هم ارتفاع کل)
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

  pw.Widget _numberBadge(int number, pw.Font boldFont) {
    return pw.Container(
      width: 20,
      height: 20,
      alignment: pw.Alignment.center,
      decoration: pw.BoxDecoration(
        color: _black,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        '$number',
        style: pw.TextStyle(font: boldFont, fontSize: 11, color: _orange),
      ),
    );
  }

  pw.Widget _exerciseThumbnail(
    Exercise? exercise,
    Map<String, pw.MemoryImage> imageCache,
    pw.MemoryImage muxcle,
  ) {
    if (exercise == null) return pw.SizedBox();

    final image = imageCache[exercise.id];

    if (image != null) {
      return pw.SizedBox(
        height: 30,
        child: pw.Image(image, fit: pw.BoxFit.contain),
      );
    }

    return pw.SizedBox();

    // return pw.Container(
    //   height: 30,
    //   alignment: pw.Alignment.center,
    //   child: pw.Text(
    //     exercise.targetMuscle,
    //     textAlign: pw.TextAlign.center,
    //     style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey500),
    //   ),
    // );
  }

  // -------------------------------------------------------------------
  // صفحه توضیحات (Notes)
  // -------------------------------------------------------------------
  pw.Widget _buildNotesPage(
    String notes,
    pw.Font boldFont,
    pw.Font regularFont,
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
                style: pw.TextStyle(
                  font: boldFont,
                  color: _black,
                  fontSize: 11,
                ),
              ),
            ),

            // متن توضیحات
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
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: _black,
                ),
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
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 11,
                  color: _black,
                ),
              ),
              pw.SizedBox(width: 2),
              pw.Container(
                width: 17,
                height: 17,
                child: pw.Image(instagramIcon),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _goalLabel(ProgramGoal goal) => switch (goal) {
    ProgramGoal.hypertrophy => 'عضله سازی',
    ProgramGoal.strength => 'قدرتی',
    ProgramGoal.fatLoss => 'چربی سوزی',
    ProgramGoal.endurance => 'استقامتی',
    ProgramGoal.rehabilitation => 'توانبخشی',
  };

  String _levelLabel(ProgramLevel level) => switch (level) {
    ProgramLevel.beginner => 'مبتدی تا متوسط',
    ProgramLevel.intermediate => 'متوسط',
    ProgramLevel.advanced => 'پیشرفته',
  };

  String _convertToPersianDate(DateTime date) {
    try {
      final jalali = Jalali.fromDateTime(date);
      return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
    } catch (e) {
      // در صورت بروز خطا، تاریخ میلادی را برگردان
      return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
    }
  }
}
