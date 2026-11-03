import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class EmptyDayExercises extends StatelessWidget {
  const EmptyDayExercises({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'برای این روز تمرینی ثبت نشده است',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('با دکمه', style: AppTextStyles.subtitle),
                const SizedBox(width: 2),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedTaskAdd01,
                  size: 16,
                  color: AppColors.textSecondary,
                  strokeWidth: 1.2,
                ),
                const SizedBox(width: 4),
                Text('تمرین اضافه کنید', style: AppTextStyles.subtitle),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
