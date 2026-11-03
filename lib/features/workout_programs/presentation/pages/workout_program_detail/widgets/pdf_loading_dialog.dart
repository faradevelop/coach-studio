import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/dialogs/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class PdfLoadingDialog extends StatelessWidget {
  const PdfLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      maxWidth: 260,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.flickr(
              leftDotColor: AppColors.primary,
              rightDotColor: AppColors.secondary,
              size: 42,
            ),
            const SizedBox(height: 20),
            Text(
              'در حال ساخت PDF',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('لطفاً کمی صبر کنید...', style: AppTextStyles.subtitle),
          ],
        ),
      ),
    );
  }
}
