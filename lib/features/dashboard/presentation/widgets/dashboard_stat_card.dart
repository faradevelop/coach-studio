import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// One statistic. Never shows a number unless [value] is real data:
/// loading → animated dots, error → retry affordance.
///
/// [iconContainerColor] is the tone of the card: the icon sits on a soft
/// tint of it, so pass an [icon] drawn in that same colour.
class DashboardStatCard extends StatelessWidget {
  final Widget icon;
  final Color iconContainerColor;
  final String label;
  final int? value;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.iconContainerColor,
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
        color: iconContainerColor,
        size: 22,
      );
    }
    return Text(
      value!.persianNumber,
      style: AppTextStyles.titleMedium.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      onTap: onTap,
      radius: AppRadius.lg,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconContainerColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: icon,
          ),
          const SizedBox(height: 12),
          Text(
            hasError ? 'تلاش مجدد' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: hasError ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 32,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: _buildValue(),
            ),
          ),
        ],
      ),
    );
  }
}
