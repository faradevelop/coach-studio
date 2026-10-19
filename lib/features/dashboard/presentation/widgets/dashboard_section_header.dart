import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HugeIcon(
          icon: HugeIcons.strokeRounded24HoursClock,
          color: AppColors.primary,
          size: 21,
          strokeWidth: 2,
        ),
        const SizedBox(width: 8),
        Text(title, style: AppTextStyles.titleMedium.copyWith(fontSize: 13)),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Text(
                actionLabel!,
                style: AppTextStyles.titleMedium.copyWith(
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
