import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/dialogs/app_dialog.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:material_ui/material_ui.dart';

/// Pops the selected target day (int), or null when cancelled.
class MoveToDayDialog extends StatefulWidget {
  final int currentDay;
  final int totalDays;

  /// day -> number of exercises already on that day.
  final Map<int, int> exerciseCounts;

  const MoveToDayDialog({
    super.key,
    required this.currentDay,
    required this.totalDays,
    required this.exerciseCounts,
  });

  @override
  State<MoveToDayDialog> createState() => _MoveToDayDialogState();
}

class _MoveToDayDialogState extends State<MoveToDayDialog> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final days = [
      for (var d = 1; d <= widget.totalDays; d++)
        if (d != widget.currentDay) d,
    ];

    return AppDialog(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'انتقال تمرین',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تمرین به انتهای روز انتخاب‌شده اضافه می‌شود.',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 18),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final day in days)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _DayOptionTile(
                        day: day,
                        count: widget.exerciseCounts[day] ?? 0,
                        isSelected: _selected == day,
                        onTap: () => setState(() => _selected = day),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'انصراف',
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.compact,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  text: 'انتقال',
                  size: AppButtonSize.compact,
                  // Disabled until a day is chosen.
                  onPressed: _selected == null
                      ? null
                      : () => Navigator.of(context).pop(_selected),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayOptionTile extends StatelessWidget {
  final int day;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayOptionTile({
    required this.day,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      selected: isSelected,
      elevated: false,
      radius: AppRadius.lg - 4,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          // Radio indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: isSelected ? AppColors.secondary : AppColors.disabled,
                width: isSelected ? 6 : 1.4,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'روز ${day.persianNumber}',
              style: AppTextStyles.body.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            count == 0 ? 'بدون تمرین' : '${count.persianNumber} تمرین',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
