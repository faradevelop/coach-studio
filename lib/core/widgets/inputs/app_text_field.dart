import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Shared text input. Borders, fill, label and focus colors come from
/// `AppTheme.inputDecorationTheme`; only content-specific bits live here.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool obscureText;
  final Widget? prefixIcn;
  final TextInputType? keyboardType;

  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.maxLines = 1,
    this.obscureText = false,
    this.prefixIcn,
    this.keyboardType,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
            child: Text(
              widget.label!,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: _isObscured ? 1 : widget.maxLines,
          obscureText: _isObscured,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.bodySmall,
            prefixIcon: widget.prefixIcn != null
                ? Padding(
                    padding: EdgeInsetsDirectional.only(start: 8),
                    child: widget.prefixIcn,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 38,
              minHeight: 16,
            ),
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                    icon: HugeIcon(
                      icon: _isObscured
                          ? HugeIcons.strokeRoundedView
                          : HugeIcons.strokeRoundedViewOffSlash,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  )
                : null,
          ),
          validator: widget.validator,
        ),
      ],
    );
  }
}
