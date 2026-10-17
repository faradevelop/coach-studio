import 'package:coach_studio/core/localization/app_number_formatter.dart';

extension AppNumberExtension on Object? {
  String get persianNumber {
    return AppNumberFormatter.toPersian(this);
  }

  String get englishNumber {
    return AppNumberFormatter.toEnglish(this);
  }
}
