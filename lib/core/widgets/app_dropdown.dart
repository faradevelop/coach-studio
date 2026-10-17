import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.value,
    this.validator,
  });

  static final _itemStyle = AppTextStyles.body.copyWith(fontSize: 15);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        // Drop down menu style
        canvasColor: AppColors.surface,
        highlightColor: AppColors.secondary.withValues(alpha: 0.12),
        hoverColor: AppColors.secondary.withValues(alpha: 0.08),
        focusColor: AppColors.secondary.withValues(alpha: 0.15),
      ),
      child: DropdownButtonFormField<T>(
        validator: validator,
        autovalidateMode: validator == null
            ? AutovalidateMode.disabled
            : AutovalidateMode.onUserInteraction,
        initialValue: items.contains(value) ? value : null,
        style: _itemStyle,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
        ),
        dropdownColor: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        menuMaxHeight: 280,
        // Fill / borders / label styles come from the input theme.
        decoration: InputDecoration(labelText: label),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabel(item).persianNumber, style: _itemStyle),
          );
        }).toList(),
        onChanged: onChanged,
        selectedItemBuilder: (context) {
          return items.map((item) {
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(itemLabel(item).persianNumber, style: _itemStyle),
            );
          }).toList();
        },
      ),
    );
  }
}
