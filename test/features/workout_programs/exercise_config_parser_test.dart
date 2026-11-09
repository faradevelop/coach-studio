import 'package:coach_studio/features/workout_programs/presentation/widgets/exercise_config/exercise_config_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parse*', () {
    test('invalid input falls back to the minimum', () {
      expect(ExerciseConfigParser.parseSets('abc'), 1);
      expect(ExerciseConfigParser.parseRest(''), 0);
    });

    test('Persian digits are understood', () {
      expect(ExerciseConfigParser.parseSets('۳'), 3);
    });

    test('values are clamped to the allowed range', () {
      expect(
        ExerciseConfigParser.parseSets('500'),
        ExerciseConfigParser.maxSets,
      );
      expect(
        ExerciseConfigParser.parseRest('-5'),
        ExerciseConfigParser.minRest,
      );
    });
  });

  group('buildReps', () {
    test('a single value applies to every set', () {
      expect(ExerciseConfigParser.buildReps(['10'], 3), [10, 10, 10]);
    });

    test('values are positional and missing ones use the minimum', () {
      expect(ExerciseConfigParser.buildReps(['10', '8'], 3), [10, 8, 1]);
    });
  });

  test('resizeReps grows and shrinks in place', () {
    final reps = [10, 8];
    ExerciseConfigParser.resizeReps(reps, 4);
    expect(reps, [10, 8, 1, 1]);
    ExerciseConfigParser.resizeReps(reps, 1);
    expect(reps, [10]);
  });

  test('blank tempo becomes the default dash', () {
    expect(ExerciseConfigParser.normalizeTempo('   '), '-');
    expect(ExerciseConfigParser.normalizeTempo(' 2-0-1 '), '2-0-1');
  });
}
