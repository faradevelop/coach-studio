import 'package:flutter/widgets.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';

/// Centralized, MediaQuery.sizeOf-based screen classification. Use this
/// instead of ad-hoc MediaQuery/LayoutBuilder checks when a widget genuinely
/// needs to branch on the *device* size (not the width of its own parent —
/// for that, use [ResponsiveGrid] or a local LayoutBuilder).
extension ResponsiveContext on BuildContext {
  AppScreenSize get screenSize {
    final width = MediaQuery.sizeOf(this).width;
    if (width >= AppBreakpoints.tablet) return AppScreenSize.desktop;
    if (width >= AppBreakpoints.mobile) return AppScreenSize.tablet;
    return AppScreenSize.mobile;
  }

  bool get isMobile => screenSize == AppScreenSize.mobile;
  bool get isTablet => screenSize == AppScreenSize.tablet;
  bool get isDesktop => screenSize == AppScreenSize.desktop;
}
