import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_surface.dart';
import 'package:flutter/material.dart';

class WizardSectionLabel extends StatelessWidget {
  final String text;

  const WizardSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

class WizardMetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color softColor;

  const WizardMetaChip({
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

/// Full-width wizard card. Thin wrapper over [AppSurface].
class WizardGlassCard extends StatelessWidget {
  final Widget child;

  const WizardGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: const EdgeInsets.all(22),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}
