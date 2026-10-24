import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/core/widgets/display/app_tag.dart';
import 'package:coach_studio/core/widgets/display/app_info_chip.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
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
    return AppSurface(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          Stack(
            children: [
              Container(
                height: 85,
                width: double.infinity,
                margin: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadius.xl - 3),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/athlete_woman.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Center(
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: 36,
                      color: AppColors.primary.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
              if (program.isTemplate)
                Positioned(top: 9, left: 9, child: AppTag(text: 'پیش‌نویس')),
            ],
          ),

          const SizedBox(height: AppSpacing.md - 2),

          // Title + menu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Text(
                    program.title,
                    maxLines: 1,
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
              '${program.daysPerWeek.persianNumber} روز در هفته',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11,
                color: AppColors.textPrimary.withValues(alpha: 0.65),
              ),
            ),
          ),
          const Divider(thickness: 1, indent: 10, endIndent: 8),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: AppInfoChip(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedTarget02,
                      size: 15,
                      color: AppColors.secondary,
                      strokeWidth: 2,
                    ),
                    text: program.goal.label,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppInfoChip(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedLowSignal,
                      size: 15,
                      color: AppColors.secondary,
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
    // Color / shape / elevation come from AppTheme.popupMenuTheme.
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      iconSize: 18,
      onSelected: (value) async {
        switch (value) {
          case 'copy':
            onCopy();
            break;
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'copy', child: Text('کپی')),
        if (program.athleteId == null)
          PopupMenuItem(
            value: 'delete',
            child: Text('حذف', style: TextStyle(color: AppColors.error)),
          ),
      ],
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedMoreHorizontalCircle01,
        size: 22,
        color: AppColors.accent,
      ),
    );
  }
}
