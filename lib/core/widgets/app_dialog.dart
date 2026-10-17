import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({super.key, required this.child, this.maxWidth = 500});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
