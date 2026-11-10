import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Filter pill shared by the exercise / athlete / program filter bars.
class AppFilterChip extends StatelessWidget {
  final String label;
  final String? activeLabel;
  final bool? isActive; // defaults to `activeLabel != null`
  final VoidCallback onTap;
  final VoidCallback onClear;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.onTap,
    required this.onClear,
    this.activeLabel,
    this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final active = isActive ?? activeLabel != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsetsDirectional.only(
          end: active ? 12 : 14,
          start: active ? 12 : 14,
          top: 8,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.outline,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              active ? '$label : $activeLabel' : label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
