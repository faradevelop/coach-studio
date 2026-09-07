import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AppStepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const AppStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 100,
  });

  void _decrement() {
    if (value > min) onChanged(value - 1);
  }

  void _increment() {
    if (value < max) onChanged(value + 1);
  }

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > min;
    final canIncrement = value < max;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.charcoal.withValues(alpha: 0.65),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.teal,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppColors.glass,
        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.4),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _StepperButton(
            icon: HugeIcons.strokeRoundedMinusSign,
            enabled: canDecrement,
            onTap: _decrement,
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 36,
            child: Text(
              value.persianNumber,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(width: 14),
          _StepperButton(
            icon: HugeIcons.strokeRoundedPlusSign,
            enabled: canIncrement,
            onTap: _increment,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final dynamic icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        splashColor: AppColors.teal.withValues(alpha: 0.12),
        highlightColor: AppColors.teal.withValues(alpha: 0.06),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.tealSoft.withValues(alpha: 0.5)
                : AppColors.glass.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled
                  ? AppColors.teal.withValues(alpha: 0.22)
                  : AppColors.glassBorderSoft,
              width: 1,
            ),
          ),
          child: Center(
            child: HugeIcon(
              icon: icon,
              size: 16,
              color: enabled
                  ? AppColors.tealDark
                  : AppColors.charcoal.withValues(alpha: 0.28),
            ),
          ),
        ),
      ),
    );
  }
}
