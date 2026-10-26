import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Shadow tokens for Coach Studio.
///
/// Shadows are intentionally subtle and compact.
/// The goal is to communicate elevation, not create a visible glow
/// around every surface.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> none = [];

  // ---------------------------------------------------------------------------
  // Surfaces
  // ---------------------------------------------------------------------------

  /// Default elevation for cards and elevated surfaces.
  ///
  /// Small vertical offset + low opacity creates a clean, modern separation
  /// from the background without a large diffuse halo.
  static final List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.045),
      blurRadius: 10,
      spreadRadius: -1,
      offset: const Offset(0, 3),
    ),
  ];

  /// Slightly stronger elevation for important floating surfaces.
  ///
  /// Used for floating navigation, dialogs and bottom sheets.
  static final List<BoxShadow> overlay = [
    BoxShadow(
      color: AppColors.textPrimary.withValues(alpha: 0.075),
      blurRadius: 16,
      spreadRadius: -2,
      offset: const Offset(0, 6),
    ),
  ];

  // ---------------------------------------------------------------------------
  // Brand effects
  // ---------------------------------------------------------------------------

  /// Subtle orange accent glow for primary actions.
  ///
  /// This is intentionally much weaker than a traditional "glow".
  static final List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.18),
      blurRadius: 10,
      spreadRadius: -2,
      offset: const Offset(0, 4),
    ),
  ];

  /// Subtle accent glow for secondary/accent actions.
  static final List<BoxShadow> accentGlow = [
    BoxShadow(
      color: AppColors.accent.withValues(alpha: 0.16),
      blurRadius: 10,
      spreadRadius: -2,
      offset: const Offset(0, 4),
    ),
  ];
}
