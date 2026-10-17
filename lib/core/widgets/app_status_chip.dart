import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum AppStatusType { success, info, warning, error }

/// Status pill: coloured dot + label on a tinted background
/// (Active / In Progress / Pending / Overdue in the design reference).
class AppStatusChip extends StatelessWidget {
  final String label;
  final AppStatusType type;
  final bool showDot;

  const AppStatusChip({
    super.key,
    required this.label,
    required this.type,
    this.showDot = true,
  });

  Color get _background => switch (type) {
    AppStatusType.success => AppColors.successSoft,
    AppStatusType.info => AppColors.infoSoft,
    AppStatusType.warning => AppColors.warningSoft,
    AppStatusType.error => AppColors.errorSoft,
  };

  Color get _dot => switch (type) {
    AppStatusType.success => AppColors.success,
    AppStatusType.info => AppColors.info,
    AppStatusType.warning => AppColors.warning,
    AppStatusType.error => AppColors.error,
  };

  Color get _foreground => switch (type) {
    AppStatusType.success => AppColors.successDark,
    AppStatusType.info => AppColors.primaryDark,
    AppStatusType.warning => AppColors.warningDark,
    AppStatusType.error => AppColors.errorDark,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: _dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: _foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
