import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_shadows.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// The one flat card / surface of the app: white, hairline border, soft
/// shadow. Replaces the many hand-rolled "glass" cards.
///
///  * base        -> `AppSurface(child: ...)`
///  * flat        -> `elevated: false` (no shadow, e.g. nested rows)
///  * interactive -> pass [onTap] (ripple + pointer feedback)
///  * selected    -> `selected: true` (mint border + soft mint fill)
///
/// The surface does not force its width; wrap the child in
/// `SizedBox(width: double.infinity)` (or put it in a stretched Column)
/// when a full-width card is needed.
class AppSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool elevated;
  final bool selected;
  final VoidCallback? onTap;

  const AppSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadius.xl,
    this.elevated = true,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: elevated ? AppShadows.card : AppShadows.none,
      ),
      child: Material(
        color: selected ? AppColors.secondarySoft : AppColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(
            color: selected ? AppColors.secondary : AppColors.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
