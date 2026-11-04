// lib/features/workout_programs/presentation/widgets/exercise_config/exercise_config_parser.dart
import 'package:coach_studio/core/localization/formatters/app_number_formatter.dart';

/// Pure parsing / clamping rules of the exercise-config form.
/// No Flutter dependency, so it can be unit-tested directly.
abstract final class ExerciseConfigParser {
  static const int minSets = 1;
  static const int maxSets = 100;

  static const int minRest = 0;
  static const int maxRest = 600;

  static const int minReps = 1;
  static const int maxReps = 100;

  static const String defaultTempo = '-';

  static int? _tryParse(String value) =>
      int.tryParse(AppNumberFormatter.toEnglish(value).trim());

  static int parseSets(String value) =>
      (_tryParse(value) ?? minSets).clamp(minSets, maxSets);

  static int parseRest(String value) =>
      (_tryParse(value) ?? minRest).clamp(minRest, maxRest);

  static int parseRep(String value) =>
      (_tryParse(value) ?? minReps).clamp(minReps, maxReps);

  /// Builds one rep value per set.
  ///
  /// - a single raw value is applied to every set;
  /// - otherwise values are taken positionally, missing ones become [minReps].
  static List<int> buildReps(List<String> raw, int setsCount) {
    return List<int>.generate(setsCount, (index) {
      if (raw.length == 1) return parseRep(raw.first);
      if (index < raw.length) return parseRep(raw[index]);
      return minReps;
    });
  }

  /// Grows (with [minReps]) or shrinks [reps] in place to [setsCount].
  static void resizeReps(List<int> reps, int setsCount) {
    if (reps.length < setsCount) {
      reps.addAll(List<int>.filled(setsCount - reps.length, minReps));
    } else if (reps.length > setsCount) {
      reps.removeRange(setsCount, reps.length);
    }
  }

  static String normalizeTempo(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? defaultTempo : trimmed;
  }
}
