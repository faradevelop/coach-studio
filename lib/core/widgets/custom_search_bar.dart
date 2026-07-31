import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final Function(String) onChanged;
  const CustomSearchBar({
    super.key,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: TextField(
        controller: controller,
        cursorColor: AppColors.orange,
        style: const TextStyle(color: AppColors.charcoal, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppColors.charcoal.withOpacity(0.45),
            fontSize: 15,
          ),
          suffixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.orange,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
