import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';

/// Mirrors the Backend's `status` query values (`all|template|assigned`).
enum ProgramStatusFilter {
  all,
  template,
  assigned;

  String get label => switch (this) {
    ProgramStatusFilter.all => 'همه',
    ProgramStatusFilter.template => 'پیش‌نویس',
    ProgramStatusFilter.assigned => 'اختصاص‌یافته',
  };
}

class WorkoutProgramFilter {
  final String search;
  final ProgramStatusFilter status;
  final ProgramGoal? goal;
  final ProgramLevel? level;

  const WorkoutProgramFilter({
    this.search = '',
    this.status = ProgramStatusFilter.all,
    this.goal,
    this.level,
  });

  bool get isEmpty =>
      search.isEmpty &&
      status == ProgramStatusFilter.all &&
      goal == null &&
      level == null;

  WorkoutProgramFilter copyWith({
    String? search,
    ProgramStatusFilter? status,
    ProgramGoal? goal,
    ProgramLevel? level,
    bool clearGoal = false,
    bool clearLevel = false,
  }) => WorkoutProgramFilter(
    search: search ?? this.search,
    status: status ?? this.status,
    goal: clearGoal ? null : (goal ?? this.goal),
    level: clearLevel ? null : (level ?? this.level),
  );
}
