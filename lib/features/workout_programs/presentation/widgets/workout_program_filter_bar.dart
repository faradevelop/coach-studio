import 'package:coach_studio/core/widgets/display/app_filter_chip.dart';
import 'package:coach_studio/core/widgets/sheets/multi_select_bottom_sheet.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_filter.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';
import 'package:flutter/material.dart';

/// Goal / level chips under the programs search field.
class WorkoutProgramFilterBar extends StatelessWidget {
  final WorkoutProgramFilter filter;
  final ValueChanged<WorkoutProgramFilter> onChanged;

  const WorkoutProgramFilterBar({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          AppFilterChip(
            label: 'هدف',
            activeLabel: filter.goal?.label,
            onTap: () => MultiSelectBottomSheet.show<ProgramGoal>(
              context: context,
              title: 'فیلتر بر اساس هدف',
              options: ProgramGoal.values,
              labelBuilder: (g) => g.label,
              initialSelected: filter.goal == null ? [] : [filter.goal!],
              singleSelect: true,
              onApply: (s) => onChanged(
                s.isEmpty
                    ? filter.copyWith(clearGoal: true)
                    : filter.copyWith(goal: s.first),
              ),
            ),
            onClear: () => onChanged(filter.copyWith(clearGoal: true)),
          ),
          const SizedBox(width: 8),
          AppFilterChip(
            label: 'سطح',
            activeLabel: filter.level?.label,
            onTap: () => MultiSelectBottomSheet.show<ProgramLevel>(
              context: context,
              title: 'فیلتر بر اساس سطح',
              options: ProgramLevel.values,
              labelBuilder: (l) => l.label,
              initialSelected: filter.level == null ? [] : [filter.level!],
              singleSelect: true,
              onApply: (s) => onChanged(
                s.isEmpty
                    ? filter.copyWith(clearLevel: true)
                    : filter.copyWith(level: s.first),
              ),
            ),
            onClear: () => onChanged(filter.copyWith(clearLevel: true)),
          ),
        ],
      ),
    );
  }
}
