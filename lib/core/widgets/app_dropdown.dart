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

  static const Color _orange = Color(0xFFFF6B35);
  static const Color _charcoal = Color(0xFF2D2D2D);
  static const Color _cream = Color(0xFFFFF8F0);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        // Drop down menu style
        canvasColor: _cream,
        highlightColor: _orange.withOpacity(0.12),
        hoverColor: _orange.withOpacity(0.08),
        focusColor: _orange.withOpacity(0.15),
      ),
      child: DropdownButtonFormField<T>(
        initialValue: items.contains(value) ? value : null,
        style: const TextStyle(
          color: _charcoal,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: _charcoal.withOpacity(0.6),
        ),
        dropdownColor: _cream,
        borderRadius: BorderRadius.circular(20),
        menuMaxHeight: 280,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: _charcoal.withOpacity(0.7),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: const TextStyle(
            color: _orange,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.55),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _orange, width: 1.6),
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              itemLabel(item),
              style: const TextStyle(
                color: _charcoal,
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
                  color: _charcoal,
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
