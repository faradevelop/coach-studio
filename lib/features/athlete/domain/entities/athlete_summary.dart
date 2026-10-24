import 'package:coach_studio/features/athlete/domain/entities/athlete.dart';

class AthleteSummary {
  final int total;
  final int active;
  final int archived;
  final List<Athlete> recent;

  const AthleteSummary({
    required this.total,
    required this.active,
    required this.archived,
    required this.recent,
  });

  factory AthleteSummary.fromAthletes(List<Athlete> athletes) {
    return AthleteSummary(
      total: athletes.length,
      active: athletes.where((a) => a.isArchived == false).length,
      archived: athletes.where((a) => a.isArchived).length,
      recent: athletes
          .where((a) => a.createdAt?.month == DateTime.now().month)
          .toList(),
    );
  }
}
