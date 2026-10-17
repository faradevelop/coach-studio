import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  // Titles
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.charcoal,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
    letterSpacing: -0.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.charcoal,
    letterSpacing: -0.2,
  );

  // Body
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.charcoal,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.muted,
    height: 1.35,
  );

  static TextStyle get subtitle => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.charcoal.withValues(alpha: 0.65),
    height: 1.35,
  );

  // Labels / Buttons
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.charcoal,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.onOrange,
    letterSpacing: 0.2,
    height: 1.3,
  );
}
