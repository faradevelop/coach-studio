import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;

  final T? value;

  final List<T> items;

  final String Function(T) itemLabel;

  final ValueChanged<T?> onChanged;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: items.contains(value) ? value : null,

      decoration: InputDecoration(labelText: label),

      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(itemLabel(item)));
      }).toList(),

      onChanged: onChanged,
    );
  }
}
