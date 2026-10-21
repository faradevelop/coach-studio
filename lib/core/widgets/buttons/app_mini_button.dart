import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_shadows.dart';
import 'package:flutter/material.dart';

class AppMiniButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  final Widget icon;
  final double? radius;

  const AppMiniButton({
    super.key,
    required this.onTap,
    required this.color,
    required this.icon,
    this.radius,
  });

  AppMiniButton.back({super.key, required this.onTap})
    : icon = Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 18,
        color: AppColors.textPrimary,
      ),
      color = AppColors.surface,
      radius = AppRadius.full;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: radius == null ? 28 : 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius ?? AppRadius.lg),
          border: Border.all(color: AppColors.outline),
          boxShadow: AppShadows.card,
        ),
        child: Directionality(textDirection: TextDirection.ltr, child: icon),
      ),
    );
  }
}
