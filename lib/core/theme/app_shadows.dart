import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Elevation tokens. Use these instead of hand-written BoxShadow lists.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];

  /// Cards / elevated surfaces: one very soft, diffuse shadow.
  static final List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Dialogs, bottom sheets, floating nav.
  static final List<BoxShadow> overlay = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.12),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  /// Glow under primary (orange) CTAs.
  static final List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.32),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Glow under accent (indigo) CTAs.
  static final List<BoxShadow> accentGlow = [
    BoxShadow(
      color: AppColors.accent.withValues(alpha: 0.30),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
