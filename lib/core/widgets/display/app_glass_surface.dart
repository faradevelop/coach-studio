import 'dart:ui' show ImageFilter;

import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_shadows.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Translucent glass surface for floating / highlighted elements.
///
/// When [blur] is enabled, the widget creates a stronger glassmorphism effect
/// using backdrop blur, translucent gradients, highlights and a subtle border.
class AppGlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool elevated;
  final bool blur;

  /// Backdrop blur intensity.
  final double blurSigma;

  final VoidCallback? onTap;

  const AppGlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadius.xl,
    this.elevated = true,
    this.blur = false,
    this.blurSigma = 36,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    final padded = Padding(padding: padding, child: child);

    final content = onTap == null
        ? padded
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              splashColor: AppColors.primary.withValues(alpha: 0.08),
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: padded,
            ),
          );

    // ─────────────────────────────────────────────────────────────
    // Normal surface
    // ─────────────────────────────────────────────────────────────

    if (!blur) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.glassHighlight, AppColors.glassFill],
          ),
          border: Border.all(color: AppColors.glassBorder, width: 0.8),
          boxShadow: elevated ? AppShadows.card : AppShadows.none,
        ),
        child: content,
      );
    }

    // ─────────────────────────────────────────────────────────────
    // Strong glass
    // ─────────────────────────────────────────────────────────────

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: elevated ? AppShadows.overlay : AppShadows.none,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,

              // More transparent glass.
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Bright glass highlight.
                  Colors.white.withValues(alpha: 0.08),

                  // Main translucent glass body.
                  AppColors.glassFill.withValues(alpha: 0.08),

                  // Slightly denser bottom.
                  AppColors.glassFill.withValues(alpha: 0.04),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),

              // Thin bright glass edge.
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.32),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Subtle inner highlight at the top.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                ),

                content,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
