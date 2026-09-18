import 'package:flutter/material.dart';

/// One column-count rule: "from this width, use this many columns".
class ResponsiveGridBreakpoint {
  final double minWidth;
  final int columns;

  const ResponsiveGridBreakpoint({
    required this.minWidth,
    required this.columns,
  });
}

/// A grid whose column count adapts to the width *it is given* (via a local
/// LayoutBuilder — the correct place for one, since this genuinely depends
/// on the parent's constraints, not the device size). Each caller supplies
/// its own [breakpoints], so column logic is never duplicated or hardcoded
/// per page, and pages stay in control of their own layout shape.
class ResponsiveGrid extends StatelessWidget {
  final List<ResponsiveGridBreakpoint> breakpoints; // any order
  final double itemExtent;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry padding;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.breakpoints,
    required this.itemExtent,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = EdgeInsets.zero,
    this.mainAxisSpacing = 14,
    this.crossAxisSpacing = 14,
  });

  int _columnsFor(double width) {
    final sorted = [...breakpoints]
      ..sort((a, b) => a.minWidth.compareTo(b.minWidth));
    var columns = sorted.first.columns;
    for (final bp in sorted) {
      if (width >= bp.minWidth) columns = bp.columns;
    }
    return columns;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: padding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columnsFor(constraints.maxWidth),
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisExtent: itemExtent,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
