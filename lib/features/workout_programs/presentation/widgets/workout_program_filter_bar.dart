import 'package:coach_studio/core/theme/app_colors.dart';
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
          _FilterChip(
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
          _FilterChip(
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

class _FilterChip extends StatelessWidget {
  final String label;
  final String? activeLabel;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _FilterChip({
    required this.label,
    required this.activeLabel,
    required this.onTap,
    required this.onClear,
  });

  bool get _isActive => activeLabel != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _isActive ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isActive ? AppColors.primary : AppColors.outline,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isActive ? '$label : $activeLabel' : label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _isActive
                    ? AppColors.primaryDark
                    : AppColors.textPrimary,
              ),
            ),
            if (_isActive) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
