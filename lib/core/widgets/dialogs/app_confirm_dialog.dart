import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/dialogs/app_dialog.dart';
import 'package:flutter/material.dart';

/// Two-button confirmation dialog (icon + title + message). Pops `true`
/// on confirm and `false` on cancel. Used by the delete / copy / logout
/// dialogs so they all look and behave the same.
class AppConfirmDialog extends StatelessWidget {
  final Widget icon;

  /// Tint of the circle behind [icon].
  final Color color;
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  /// Uses the red (destructive) confirm button instead of the primary one.
  final bool destructive;

  const AppConfirmDialog({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmText,
    this.cancelText = 'لغو',
    this.color = AppColors.primary,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: icon,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6),
            child: Text(
              message,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.textPrimary.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: cancelText,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.compact,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: confirmText,
                  variant: destructive
                      ? AppButtonVariant.destructive
                      : AppButtonVariant.primary,
                  size: AppButtonSize.compact,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
