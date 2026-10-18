import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({
    super.key,
    required this.itemName,
    required this.title,
    this.message,
  });
  final String title;
  final String itemName;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return AppConfirmDialog(
      destructive: true,
      color: AppColors.error,
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedDelete03,
        size: 24,
        color: AppColors.error,
        strokeWidth: 2,
      ),
      title: 'حذف $title',
      message:
          message ??
          'آیا از حذف $title ${itemName.isNotEmpty ? "\"$itemName\"" : ""} مطمئن هستید؟',
      confirmText: 'حذف',
    );
  }
}
