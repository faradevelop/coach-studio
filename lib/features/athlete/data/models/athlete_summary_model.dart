import 'package:coach_studio/features/athlete/data/models/athlete_model.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_summary.dart';

class AthleteSummaryModel {
  final int total;
  final int active;
  final int archived;
  final List<AthleteModel> recent;

  const AthleteSummaryModel({
    required this.total,
    required this.active,
    required this.archived,
    required this.recent,
  });

  factory AthleteSummaryModel.fromJson(Map<String, dynamic> json) {
    return AthleteSummaryModel(
      total: json['total'] as int,
      active: json['active'] as int,
      archived: json['archived'] as int,
      recent: (json['recent'] as List<dynamic>? ?? [])
          .map((e) => AthleteModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  AthleteSummary toEntity() => AthleteSummary(
    total: total,
    active: active,
    archived: archived,
    recent: recent.map((e) => e.toEntity()).toList(),
  );
}
