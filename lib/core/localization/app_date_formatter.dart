import 'package:persian_number_utility/persian_number_utility.dart';

abstract final class AppDateFormatter {
  /// Converts a Gregorian [DateTime] to a Persian/Jalali date.
  ///
  /// Example:
  /// 2026-09-07 → ۱۴۰۵/۰۶/۱۶
  static String toPersianDate(DateTime date) {
    return date.toPersianDate();
  }
}
