import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppTag extends StatelessWidget {
  final Widget? icon;
  final String text;

  const AppTag({super.key, this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 2, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 5)],
          Flexible(
            child: Text(
              text.persianNumber,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.label.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
