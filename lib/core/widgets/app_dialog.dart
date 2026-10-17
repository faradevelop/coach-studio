import 'package:coach_studio/core/widgets/app_surface.dart';
import 'package:flutter/material.dart';

/// Shared dialog shell: a transparent [Dialog] hosting one flat
/// [AppSurface]. Callers pass only the content; they no longer need to
/// draw their own container / blur.
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.child,
    this.maxWidth = 500,
    this.padding = const EdgeInsets.fromLTRB(24, 24, 24, 20),
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: AppSurface(radius: 28, padding: padding, child: child),
      ),
    );
  }
}
