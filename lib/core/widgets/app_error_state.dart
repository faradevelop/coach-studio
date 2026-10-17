import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_surface.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppErrorState extends StatelessWidget {
  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    this.title = 'خطا در دریافت اطلاعات',
    this.message = 'لطفاً دوباره تلاش کنید',
    this.retryLabel = 'تلاش مجدد',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: AppSurface(
            radius: AppRadius.xl + 4,
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedAlert02,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm + 2),

                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  if (onRetry != null) ...[
                    const SizedBox(height: AppSpacing.lg + 4),
                    AppButton(text: retryLabel, onPressed: onRetry),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
