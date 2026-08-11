import 'dart:ui';

import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class EmptyExercises extends StatelessWidget {
  const EmptyExercises({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glass circle icon
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    size: 36,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text('تمرینی وجود ندارد!', style: AppTextStyles.titleMedium),

            const SizedBox(height: AppSpacing.sm),

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
