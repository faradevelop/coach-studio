import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Neutral informational pill (mint tint) with an optional leading icon.
/// Single implementation behind both legacy `InfoChip` classes.
class AppInfoChip extends StatelessWidget {
  final Widget? icon;
  final String text;
  final Color textColor;
  final Color? backgroundColor;

  /// Slim vertical padding (used inside dense cards).
  final bool compact;

  /// Converts latin digits in [text] to Persian digits.
  final bool persianDigits;

  const AppInfoChip({
    super.key,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.textColor = AppColors.textPrimary,
    this.compact = false,
    this.persianDigits = true,
  });

  /// Text-only chip for dense cards (slim padding, digits left as-is).
  const AppInfoChip.plain({super.key, required this.text, this.backgroundColor})
    : icon = null,
      textColor = AppColors.secondaryDark,
      compact = true,
      persianDigits = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
          ? EdgeInsets.fromLTRB(6, 2, 6, 6)
          : EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.secondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 5)],
          Flexible(
            child: Text(
              persianDigits ? text.persianNumber : text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: compact ? 10 : 12.5,
                fontWeight: compact ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
