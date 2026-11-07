import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import 'package:coach_studio/core/widgets/buttons/app_button.dart';

class AppPersianDatePicker extends StatelessWidget {
  final Jalali? value;
  final ValueChanged<Jalali> onChanged;

  final String placeholder;
  final String helpText;

  final Jalali? firstDate;
  final Jalali? lastDate;

  final String? fontFamily;

  const AppPersianDatePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.placeholder = 'انتخاب تاریخ',
    this.helpText = 'انتخاب تاریخ',
    this.firstDate,
    this.lastDate,
    this.fontFamily,
  });

  Future<void> _showPicker(BuildContext context) async {
    final picked = await showPersianDatePicker(
      context: context,

      // Force Persian localization.
      locale: const Locale('fa', 'IR'),
      textDirection: TextDirection.rtl,

      initialDate: value ?? Jalali.now(),
      firstDate: firstDate ?? Jalali(1300, 1, 1),
      lastDate: lastDate ?? Jalali.now(),

      initialEntryMode: PersianDatePickerEntryMode.calendarOnly,

      initialDatePickerMode: PersianDatePickerMode.day,

      helpText: helpText,
      cancelText: 'انصراف',
      confirmText: 'تایید',

      holidayConfig: PersianHolidayConfig(weekendDays: {7}),

      builder: (context, child) {
        final theme = Theme.of(context);

        return Localizations.override(
          context: context,
          child: Theme(
            data: theme.copyWith(
              textTheme: theme.textTheme.apply(fontFamily: fontFamily),
              primaryTextTheme: theme.primaryTextTheme.apply(
                fontFamily: fontFamily,
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: child!,
            ),
          ),
        );
      },
    );

    if (picked == null) return;

    onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        _showPicker(context);
      },
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedCalendar03,
        size: 22,
        color: AppColors.textSecondary,
        strokeWidth: 1.8,
      ),
    );
  }
}
