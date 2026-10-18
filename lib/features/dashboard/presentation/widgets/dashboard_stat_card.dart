import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/features/dashboard/presentation/widgets/dashboard_glass_card.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// One statistic. Never shows a number unless [value] is real data:
/// loading → animated dots, error → retry affordance.
class DashboardStatCard extends StatelessWidget {
  final Widget icon;
  final String label;
  final int? value;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.isLoading = false,
    this.hasError = false,
  });

  Widget _buildValue() {
    if (hasError) {
      return const Icon(
        Icons.refresh_rounded,
        size: 24,
        color: AppColors.primary,
      );
    }
    if (isLoading || value == null) {
      return LoadingAnimationWidget.waveDots(
        color: AppColors.primary,
        size: 22,
      );
    }
    return Text(
      value!.persianNumber,
      style: AppTextStyles.titleMedium.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.secondarySoft,
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 30,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _buildValue(),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hasError ? 'تلاش مجدد' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
