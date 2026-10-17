import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/app_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class InfoDialog extends StatelessWidget {
  const InfoDialog({super.key, required this.message, required this.title});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppConfirmDialog(
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedCopy02,
        size: 24,
        color: AppColors.primary,
        strokeWidth: 2,
      ),
      title: 'کپی $title',
      message: message,
      confirmText: 'تایید',
    );
  }
}
