/// Single source of truth for screen-size breakpoints and the content
/// widths pages should cap themselves at. Keeping these in one place avoids
/// magic numbers scattered across pages.
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
}

enum AppScreenSize { mobile, tablet, desktop }

/// Preferred max content widths for common content shapes. Below these
/// widths the constraint simply doesn't bind, so mobile is unaffected.
class AppContentWidth {
  AppContentWidth._();

  static const double shell =
      1000; // whole-app shell cap (matches old main.dart behavior)
  static const double form = 560; // text-field heavy forms
  static const double detail = 760; // reading-width detail/content pages
  static const double bottomNav = 420; // floating bottom navigation
}
