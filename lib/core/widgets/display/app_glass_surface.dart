import 'dart:ui' show ImageFilter;

import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_shadows.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Translucent "glass" surface for floating / highlighted elements.
///
/// By default, no backdrop blur is applied for better performance.
/// When [blur] is true, the surface gets a stronger glass effect:
/// - stronger backdrop blur
/// - more transparent surface
/// - brighter highlight
/// - more visible glass border
/// - stronger floating shadow
class AppGlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool elevated;
  final bool blur;

  /// Controls the strength of the backdrop blur.
  ///
  /// Only has an effect when [blur] is true.
  final double blurSigma;

  final VoidCallback? onTap;

  const AppGlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadius.xl,
    this.elevated = true,
    this.blur = false,
    this.blurSigma = 24,
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

    BoxDecoration decoration({required bool glass, required bool shadow}) {
      return BoxDecoration(
        borderRadius: borderRadius,

        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: glass
              ? [
                  AppColors.glassHighlight.withValues(alpha: 0.55),
                  AppColors.glassFill.withValues(alpha: 0.28),
                ]
              : const [AppColors.glassHighlight, AppColors.glassFill],
        ),

        border: Border.all(
          color: glass
              ? AppColors.glassBorder.withValues(alpha: 0.85)
              : AppColors.glassBorder,
          width: glass ? 1.2 : 0.8,
        ),

        boxShadow: shadow && elevated
            ? (glass ? AppShadows.overlay : AppShadows.card)
            : AppShadows.none,
      );
    }

    // Normal surface — cheap, no backdrop blur.
    if (!blur) {
      return DecoratedBox(
        decoration: decoration(glass: false, shadow: true),
        child: content,
      );
    }

    // Strong glass surface.
    //
    // Shadow stays outside the clip so it won't be cut off.
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
            decoration: decoration(glass: true, shadow: false),
            child: content,
          ),
        ),
      ),
    );
  }
}
