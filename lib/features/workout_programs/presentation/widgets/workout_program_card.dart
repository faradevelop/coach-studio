import 'dart:ui';

import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkoutProgramCard extends StatelessWidget {
  final WorkoutProgram program;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const WorkoutProgramCard({
    super.key,
    required this.program,
    required this.onDelete,
    required this.onTap,
  });

  String get _goalLabel {
    return switch (program.goal) {
      ProgramGoal.hypertrophy => 'هایپرتروفی',
      ProgramGoal.strength => 'قدرتی',
      ProgramGoal.fatLoss => 'چربی‌سوزی',
      ProgramGoal.endurance => 'استقامتی',
      ProgramGoal.rehabilitation => 'توان‌بخشی',
    };
  }

  String get _levelLabel {
    return switch (program.level) {
      ProgramLevel.beginner => 'مبتدی',
      ProgramLevel.intermediate => 'متوسط',
      ProgramLevel.advanced => 'پیشرفته',
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.glassBorder, width: 1.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image header
                Container(
                  height: 85,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.dirtyCream.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppColors.cream.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/athlete_woman.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Center(
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 36,
                        color: AppColors.orange.withValues(alpha: 0.45),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md - 2),

                // Title + delete
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          program.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 15,
                            height: 1.25,
                          ),
                        ),
                      ),
                      MiniButton(
                        color: AppColors.error.withValues(alpha: 0.18),
                        icon: Icon(
                          Icons.delete_rounded,
                          size: 16,
                          color: AppColors.error.withValues(alpha: 0.9),
                        ),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ),

                // Days per week
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
                  child: Text(
                    '${program.daysPerWeek} روز در هفته',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.charcoal.withValues(alpha: 0.65),
                    ),
                  ),
                ),

                const Spacer(),

                // Stats row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      _StatItem(
                        icon: Icon(
                          CupertinoIcons.flag_fill,
                          size: 16,
                          color: AppColors.orange,
                        ),
                        value: _goalLabel,
                        label: 'هدف',
                      ),
                      const _VerticalDivider(),
                      _StatItem(
                        icon: Icon(
                          Icons.bar_chart_rounded,
                          size: 20,
                          color: AppColors.orange,
                        ),
                        value: _levelLabel,
                        label: 'سطح',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md - 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final Icon icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal.withValues(alpha: 0.5),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.8,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.charcoal.withValues(alpha: 0.12),
    );
  }
}
