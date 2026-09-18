import 'package:flutter/widgets.dart';

/// Centers [child] and caps its width at [maxWidth]. On screens narrower
/// than [maxWidth] this is a no-op — the child simply fills the available
/// width, exactly as before. Use this instead of hand-rolled
/// Align+ConstrainedBox(+SizedBox) per page.
class MaxWidthBox extends StatelessWidget {
  final double maxWidth;
  final Widget child;

  /// When true, also forces the box to fill all available height
  /// (needed for the app-wide shell in main.dart).
  final bool expandHeight;

  const MaxWidthBox({
    super.key,
    required this.maxWidth,
    required this.child,
    this.expandHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = expandHeight
        ? SizedBox(height: double.infinity, child: child)
        : child;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      ),
    );
  }
}
