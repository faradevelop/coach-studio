import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:horizontal_slider/src/horizontal_slider.dart';

class AppNumberPicker extends StatelessWidget {
  final String? label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const AppNumberPicker({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 100,
  }) : assert(min <= max);

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(min, max);
    final values = List<num>.generate(max - min + 1, (index) => min + index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
            child: Text(
              label!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
            ),
          ),
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.field),
            border: Border.all(color: AppColors.outline),
          ),
          child: HorizontalPicker(
            values: values,
            valueFormatter: (value) => value.persianNumber,
            initialSelectedIndex: safeValue - min,
            pickerHeight: 56,
            itemExtent: 52,
            diameterRatio: 1.7,
            perspective: 0.003,
            onValueSelected: (selectedValue) {
              onChanged(selectedValue.toInt());
            },
            selectedTextStyle: AppTextStyles.titleMedium.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            unselectedTextStyle: AppTextStyles.titleMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            selectedItemDecoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondarySoft,
              border: Border.all(color: AppColors.secondary, width: 1),
            ),
            unselectedItemDecoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondarySoft,
            ),
          ),
        ),
      ],
    );
  }
}
