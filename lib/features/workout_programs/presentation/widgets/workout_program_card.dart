import 'dart:ui';

import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/info_chip.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class WorkoutProgramCard extends StatelessWidget {
  final WorkoutProgram program;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onTap;

  const WorkoutProgramCard({
    super.key,
    required this.program,
    required this.onDelete,
    required this.onTap,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.42),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: AppColors.glassBorder, width: 1.3),
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
                      borderRadius: BorderRadius.circular(AppRadius.lg + 2),
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
                        CustomPopupMenu(
                          program: program,
                          onDelete: onDelete,
                          onCopy: onCopy,
                        ),
                      ],
                    ),
                  ),

                  // Days per week
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                    child: Text(
                      '${program.daysPerWeek} روز در هفته',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.charcoal.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                  Divider(thickness: 1, indent: 10, endIndent: 8),

                  // Stats row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InfoChip(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedTarget02,
                              size: 15,
                              color: AppColors.teal,
                              strokeWidth: 2,
                            ),
                            text: program.goal.label,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: InfoChip(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLowSignal,
                              size: 15,
                              color: AppColors.teal,
                              strokeWidth: 2,
                            ),
                            text: program.level.label,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomPopupMenu extends StatelessWidget {
  final WorkoutProgram program;
  final VoidCallback onDelete;
  final VoidCallback onCopy;

  const CustomPopupMenu({
    super.key,
    required this.program,
    required this.onDelete,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      iconSize: 18,
      color: AppColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        switch (value) {
          case 'copy':
            onCopy();
            break;
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'copy', child: Text('کپی')),
        PopupMenuItem(
          value: 'delete',
          child: Text('حذف', style: TextStyle(color: AppColors.error)),
        ),
      ],
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedMoreHorizontalCircle01,
        size: 20,
        color: AppColors.orange,
      ),
    );
  }
}
