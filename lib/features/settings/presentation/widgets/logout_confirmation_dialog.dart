import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class LogoutConfirmationDialog extends StatelessWidget {
  const LogoutConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppConfirmDialog(
      destructive: true,
      color: AppColors.error,
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedLogoutCircle02,
        size: 20,
        color: AppColors.error,
      ),
      title: 'خروج از حساب',
      message: 'آیا برای خروج از حساب کاربری خود مطمئن هستید؟',
      cancelText: 'انصراف',
      confirmText: 'خروج',
    );
  }
}
