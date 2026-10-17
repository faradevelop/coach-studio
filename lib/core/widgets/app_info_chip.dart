import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Neutral informational pill (mint tint) with an optional leading icon.
/// Single implementation behind both legacy `InfoChip` classes.
class AppInfoChip extends StatelessWidget {
  final Widget? icon;
  final String text;

  /// Slim vertical padding (used inside dense cards).
  final bool compact;

  /// Converts latin digits in [text] to Persian digits.
  final bool persianDigits;

  const AppInfoChip({
    super.key,
    required this.text,
    this.icon,
    this.compact = false,
    this.persianDigits = true,
  });

  /// Text-only chip for dense cards (slim padding, digits left as-is).
  const AppInfoChip.plain({super.key, required this.text})
    : icon = null,
      compact = true,
      persianDigits = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: compact ? 1 : 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.12),
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
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
