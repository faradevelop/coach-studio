import 'dart:ui';

import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

class DashboardGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const DashboardGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.xl);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Material(
            color: Colors.white.withValues(alpha: 0.38),
            child: InkWell(
              onTap: onTap,
              splashColor: AppColors.orange.withValues(alpha: 0.08),
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: padding,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: AppColors.glassBorder, width: 1.1),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
