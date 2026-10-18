import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:flutter/material.dart';

/// Full-width dashboard card. Thin wrapper over [AppSurface] so existing
/// dashboard code keeps working unchanged.
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
    return AppSurface(
      padding: padding,
      onTap: onTap,
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}
