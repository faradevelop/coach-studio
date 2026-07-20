import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;

  final String label;

  final String? hint;

  final String? Function(String?)? validator;

  final int maxLines;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,

      maxLines: maxLines,

      decoration: InputDecoration(labelText: label, hintText: hint),

      validator: validator,
    );
  }
}
