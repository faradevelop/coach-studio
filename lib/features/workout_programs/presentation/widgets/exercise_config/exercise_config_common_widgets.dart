// lib/features/workout_programs/presentation/widgets/exercise_config/exercise_config_common_widgets.dart
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Section title with the orange accent bar.
/// (Formerly `WizardSectionLabel`.)
class ExerciseConfigSectionLabel extends StatelessWidget {
  final String text;

  const ExerciseConfigSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 2, bottom: 3),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small rounded pill (training system, day, ...).
/// (Formerly `WizardMetaChip`.)
class ExerciseConfigMetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color softColor;

  const ExerciseConfigMetaChip({
    super.key,
    required this.label,
    required this.color,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }
}
