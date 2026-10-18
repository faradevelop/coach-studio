import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_shadows.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Visual role of an [AppButton].
enum AppButtonVariant {
  /// Main call to action (indigo, filled). Default.
  primary,

  /// Secondary action (white, mint outline).
  secondary,

  /// Sparse highlight action (coral, filled), e.g. "view details".
  accent,

  /// Destructive action (red, filled), e.g. delete / logout.
  destructive,
}

/// Height preset of an [AppButton].
enum AppButtonSize {
  /// 48 — forms and page-level actions. Default.
  regular,

  /// 42 — dialogs and bottom sheets.
  compact,
}

/// Shared button. Existing call sites (`text`, `onPressed`, `isLoading`)
/// are unchanged and render as the primary variant.
///
/// States: default / pressed / focused (Material overlays), disabled
/// (`onPressed == null`) and loading (`isLoading`). While loading the
/// button keeps its own color (instead of turning grey) and ignores taps.
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Optional icon shown before [text].
  final Widget? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.regular,
    this.icon,
  });

  Color get _background => switch (variant) {
    AppButtonVariant.primary => AppColors.primary,
    AppButtonVariant.secondary => AppColors.surface,
    AppButtonVariant.accent => AppColors.accent,
    AppButtonVariant.destructive => AppColors.error,
  };

  Color get _foreground => switch (variant) {
    AppButtonVariant.primary => AppColors.onPrimary,
    // secondaryDark (not the light mint) keeps the label readable on white.
    AppButtonVariant.secondary => AppColors.secondaryDark,
    AppButtonVariant.accent => AppColors.onAccent,
    AppButtonVariant.destructive => AppColors.onError,
  };

  bool get _isOutlined => variant == AppButtonVariant.secondary;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;
    // A loading button looks "busy", not "disabled".
    final showDisabledLook = onPressed == null && !isLoading;

    final foreground = showDisabledLook
        ? AppColors.textPrimary.withValues(alpha: 0.45)
        : _foreground;
    final background = showDisabledLook
        ? (_isOutlined ? AppColors.surface : AppColors.disabled)
        : _background;
    final borderColor = showDisabledLook
        ? AppColors.disabled
        : AppColors.secondary;

    final style = FilledButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: background,
      disabledForegroundColor: foreground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.button),
        side: _isOutlined
            ? BorderSide(color: borderColor, width: 1.5)
            : BorderSide.none,
      ),
    );

    final label = Text(
      text,
      style: AppTextStyles.button.copyWith(color: foreground),
    );

    return SizedBox(
      width: double.infinity,
      height: size == AppButtonSize.regular ? 48 : 42,
      child: FilledButton(
        onPressed: isDisabled ? null : onPressed,
        style: style,
        child: isLoading
            ? LoadingAnimationWidget.waveDots(color: foreground, size: 24)
            : (icon == null
                  ? label
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [icon!, const SizedBox(width: 8), label],
                    )),
      ),
    );
  }
}

class MiniButton extends StatelessWidget {
  final Color color;
  final Widget icon;
  final VoidCallback onPressed;

  const MiniButton({
    super.key,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Center(child: icon),
      ),
    );
  }
}

class GlassyBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const GlassyBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outline),
          boxShadow: AppShadows.card,
        ),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
