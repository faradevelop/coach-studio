import 'dart:async';

import 'package:flutter/widgets.dart';

/// Scrolls an OUTER [ScrollController] while an item is being dragged near
/// the top/bottom edge of the scrollable's viewport.
///
/// Needed because `ReorderableColumn` builds its own (non-scrolling)
/// scrollable, so its built-in auto-scroll never moves the page.
///
/// Usage:
///  * call [start] when a drag begins and [stop] when it ends/cancels,
///  * feed pointer events through [updatePointer] (e.g. from a `Listener`),
///  * call [dispose] from the owning State's dispose.
class DragAutoScroller {
  DragAutoScroller({
    required this.controllerProvider,
    this.edgeZone = 90,
    this.maxStep = 16,
    this.interval = const Duration(milliseconds: 16),
  });

  /// Returns the outer controller. A callback (not a value) so it always
  /// reflects the current `widget.scrollController` of the owner.
  final ScrollController? Function() controllerProvider;

  /// Distance from the viewport edge where auto-scroll begins.
  final double edgeZone;

  /// Max pixels scrolled per tick (reached at the very edge).
  final double maxStep;

  final Duration interval;

  Timer? _timer;
  double? _pointerY;

  bool get isActive => _timer != null;

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => _tick());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void updatePointer(PointerEvent event) => _pointerY = event.position.dy;

  void dispose() => stop();

  void _tick() {
    final pointerY = _pointerY;
    final controller = controllerProvider();
    if (pointerY == null || controller == null || !controller.hasClients) {
      return;
    }

    final position = controller.position;
    final box = position.context.storageContext.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;

    final top = box.localToGlobal(Offset.zero).dy;
    final bottom = top + box.size.height;

    double delta = 0;
    if (pointerY > bottom - edgeZone) {
      final t = ((pointerY - (bottom - edgeZone)) / edgeZone).clamp(0.0, 1.0);
      delta = maxStep * t;
    } else if (pointerY < top + edgeZone) {
      final t = (((top + edgeZone) - pointerY) / edgeZone).clamp(0.0, 1.0);
      delta = -maxStep * t;
    }
    if (delta == 0) return;

    final target = (position.pixels + delta).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target != position.pixels) controller.jumpTo(target);
  }
}
