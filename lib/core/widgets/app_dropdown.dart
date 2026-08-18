import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        // Drop down menu style
        canvasColor: AppColors.cream,
        highlightColor: AppColors.orange.withValues(alpha: 0.12),
        hoverColor: AppColors.orange.withValues(alpha: 0.08),
        focusColor: AppColors.orange.withValues(alpha: 0.15),
      ),
      child: DropdownButtonFormField<T>(
        initialValue: items.contains(value) ? value : null,
        style: const TextStyle(
          color: AppColors.charcoal,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.charcoal.withValues(alpha: 0.6),
        ),
        dropdownColor: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        menuMaxHeight: 280,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: AppColors.charcoal.withValues(alpha: 0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: const TextStyle(
            color: AppColors.orange,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.55),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.orange, width: 1.6),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel(item),
              style: const TextStyle(
                color: AppColors.charcoal,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        selectedItemBuilder: (context) {
          return items.map((item) {
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                itemLabel(item),
                style: const TextStyle(
                  color: AppColors.charcoal,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList();
        },
      ),
    );
  }
}
