import 'package:flutter/widgets.dart';

/// Caps the system text scale so fixed-height cards don't overflow.
class TextScaleClamp extends StatelessWidget {
  final double maxScale;
  final Widget child;

  const TextScaleClamp({super.key, this.maxScale = 1.3, required this.child});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return MediaQuery(
      data: mq.copyWith(
        textScaler: mq.textScaler.clamp(maxScaleFactor: maxScale),
      ),
      child: child,
    );
  }
}
