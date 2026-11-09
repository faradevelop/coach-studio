import 'package:coach_studio/features/athlete/data/models/athlete_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('an unexpected gender value no longer breaks parsing', () {
    final model = AthleteModel.fromJson({
      'id': 'a1',
      'coachId': 'c1',
      'firstName': 'Ali',
      'lastName': 'Rezaei',
      'gender': 'other',
    });
    expect(model.gender, isNull);
    expect(model.isArchived, isFalse);
  });

  test('request json never contains coachId', () {
    final model = AthleteModel.fromJson({
      'id': 'a1',
      'coachId': 'c1',
      'firstName': 'Ali',
      'lastName': 'Rezaei',
    });
    expect(model.toRequestJson().containsKey('coachId'), isFalse);
  });
}
