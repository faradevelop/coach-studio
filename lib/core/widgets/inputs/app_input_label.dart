import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppInputLabel extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;

  const AppInputLabel({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: Text(
        text,
        textAlign: textAlign,
        style: style ?? AppTextStyles.titleMedium.copyWith(fontSize: 13),
      ),
    );
  }
}
