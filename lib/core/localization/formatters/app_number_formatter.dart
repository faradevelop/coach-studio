import 'package:persian_number_utility/persian_number_utility.dart';

abstract final class AppNumberFormatter {
  static String toPersian(Object? value) {
    if (value == null) return '';

    return value.toString().toPersianDigit();
  }

  static String toEnglish(Object? value) {
    if (value == null) return '';

    return value.toString().toEnglishDigit();
  }
}
