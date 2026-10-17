import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class EmptyExercises extends StatelessWidget {
  final bool addMessage;
  const EmptyExercises({super.key, this.addMessage = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text('تمرینی وجود ندارد!', style: AppTextStyles.titleMedium),

            const SizedBox(height: AppSpacing.sm),
            if (addMessage)
              Text(
                'با کلیک دکمه  +  اولین تمرین را بسازید',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
