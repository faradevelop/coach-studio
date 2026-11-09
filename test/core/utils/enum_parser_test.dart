import 'package:coach_studio/core/utils/enum_parser.dart';
import 'package:coach_studio/features/athlete/domain/enums/gender.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('known name is parsed', () {
    expect(tryEnumByName(Gender.values, 'female'), Gender.female);
  });

  test('unknown or non-string values return null instead of throwing', () {
    expect(tryEnumByName(Gender.values, 'other'), isNull);
    expect(tryEnumByName(Gender.values, null), isNull);
    expect(tryEnumByName(Gender.values, 5), isNull);
  });
}
