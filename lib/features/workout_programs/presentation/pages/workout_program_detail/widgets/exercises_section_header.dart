import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ExercisesSectionHeader extends StatelessWidget {
  final VoidCallback onAddPressed;

  const ExercisesSectionHeader({super.key, required this.onAddPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        ),
        Text('تمرین‌ها', style: AppTextStyles.titleMedium),
        const Spacer(),
        GestureDetector(
          onTap: onAddPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedTaskAdd01,
                  size: 18,
                  color: AppColors.onPrimary,
                  strokeWidth: 1.5,
                ),
                const SizedBox(width: 6),
                Text(
                  'تمرین جدید',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
