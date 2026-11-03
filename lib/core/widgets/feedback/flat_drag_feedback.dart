import 'package:flutter/material.dart';

/// Drag-feedback builder for `reorderables` widgets (ReorderableRow /
/// ReorderableColumn) that draws NO elevation shadow.
///
/// The package's default feedback is
/// `Material(elevation: 6, color: Colors.transparent)`, which paints a
/// rectangular shadow/outline around the dragged item's layout box
/// regardless of the item's own shape. A transparent-type Material keeps
/// the Material ancestor (ink, text styles) but paints nothing.
Widget flatDragFeedback(
  BuildContext context,
  BoxConstraints constraints,
  Widget child,
) {
  return Material(
    //type: MaterialType.transparency,
    elevation: 8,
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(20),
    child: ConstrainedBox(constraints: constraints, child: child),
  );
}
