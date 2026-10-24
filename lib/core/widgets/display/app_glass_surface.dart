import 'dart:ui' show ImageFilter;

import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_shadows.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Translucent "glass" surface for floating / highlighted elements
/// (dashboard cards, floating navigation).
///
/// Performance: by default NO blur is applied — it is just a translucent
/// white gradient with a soft border and shadow, which is cheap and safe in
/// repeated elements. Pass [blur] = true only for a single, standalone
/// element that sits over scrolling content (e.g. the floating bottom nav).
class AppGlassSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool elevated;
  final bool blur;
  final double blurSigma;
  final VoidCallback? onTap;

  const AppGlassSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadius.xl,
    this.elevated = true,
    this.blur = false,
    this.blurSigma = 12,
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

    BoxDecoration decoration({required bool shadow}) => BoxDecoration(
      borderRadius: borderRadius,
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.glassHighlight, AppColors.glassFill],
      ),
      border: Border.all(color: AppColors.glassBorder, width: 1),
      boxShadow: shadow && elevated ? AppShadows.card : AppShadows.none,
    );

    if (!blur) {
      return DecoratedBox(decoration: decoration(shadow: true), child: content);
    }

    // Shadow lives outside the clip so it is not cut off by ClipRRect.
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
            decoration: decoration(shadow: false),
            child: content,
          ),
        ),
      ),
    );
  }
}
