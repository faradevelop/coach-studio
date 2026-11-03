import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/widgets/buttons/app_mini_button.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class PdfActionButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const PdfActionButton({
    super.key,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: AppMiniButton(
        radius: AppRadius.full,
        color: AppColors.surface,
        onTap: onTap,
        icon: Padding(
          padding: const EdgeInsets.all(6.0),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedPdf02,
            size: 16,
            color: AppColors.textPrimary,
            strokeWidth: 1.2,
          ),
        ),
      ),
    );
  }
}
