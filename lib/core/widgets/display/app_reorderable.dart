import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

import '../feedback/flat_drag_feedback.dart';

/// `buildDraggableFeedback` is a per-widget parameter of `reorderables`,
/// not a ThemeData property, so the app-wide default lives in these two
/// thin wrappers. Use them instead of ReorderableRow / ReorderableColumn.
///
/// Both also switch off ink splash/highlight inside the reorderable
/// subtree only (the rest of the app keeps its ripples): a press that
/// turns into a long-press drag would otherwise leave a ripple stuck on
/// the item (or its drag feedback).
ThemeData _withoutInk(ThemeData theme) => theme.copyWith(
  splashFactory: NoSplash.splashFactory,
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  hoverColor: Colors.transparent,
);

Widget _feedback(
  BuildContext context,
  BoxConstraints constraints,
  Widget child,
) {
  return Theme(
    data: _withoutInk(Theme.of(context)),
    child: flatDragFeedback(context, constraints, child),
  );
}

class AppReorderableRow extends StatelessWidget {
  final List<Widget> children;
  final ReorderCallback onReorder;
  final bool needsLongPressDraggable;

  const AppReorderableRow({
    super.key,
    required this.children,
    required this.onReorder,
    this.needsLongPressDraggable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _withoutInk(Theme.of(context)),
      child: ReorderableRow(
        needsLongPressDraggable: needsLongPressDraggable,
        buildDraggableFeedback: _feedback,
        onReorder: onReorder,
        children: children,
      ),
    );
  }
}

class AppReorderableColumn extends StatelessWidget {
  final List<Widget> children;
  final ReorderCallback onReorder;
  final bool needsLongPressDraggable;
  final bool ignorePrimaryScrollController;
  final CrossAxisAlignment crossAxisAlignment;

  const AppReorderableColumn({
    super.key,
    required this.children,
    required this.onReorder,
    this.needsLongPressDraggable = true,
    this.ignorePrimaryScrollController = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _withoutInk(Theme.of(context)),
      child: ReorderableColumn(
        ignorePrimaryScrollController: ignorePrimaryScrollController,
        crossAxisAlignment: crossAxisAlignment,
        needsLongPressDraggable: needsLongPressDraggable,
        buildDraggableFeedback: _feedback,
        onReorder: onReorder,
        children: children,
      ),
    );
  }
}
