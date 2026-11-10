import 'package:coach_studio/core/widgets/display/app_filter_chip.dart';
import 'package:coach_studio/core/widgets/sheets/multi_select_bottom_sheet.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_filter.dart';
import 'package:flutter/material.dart';

/// Status / program / order chips under the athlete search field.
class AthleteFilterBar extends StatelessWidget {
  final AthleteFilter filter;
  final ValueChanged<AthleteFilter> onChanged;

  const AthleteFilterBar({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          AppFilterChip(
            label: 'وضعیت',
            activeLabel: filter.status.label,
            isActive: filter.status != AthleteStatus.active,
            onTap: () => MultiSelectBottomSheet.show<AthleteStatus>(
              context: context,
              title: 'فیلتر بر اساس وضعیت',
              options: AthleteStatus.values,
              labelBuilder: (s) => s.label,
              initialSelected: [filter.status],
              singleSelect: true,
              onApply: (s) => onChanged(
                filter.copyWith(
                  status: s.isEmpty ? AthleteStatus.active : s.first,
                ),
              ),
            ),
            onClear: () =>
                onChanged(filter.copyWith(status: AthleteStatus.active)),
          ),
          const SizedBox(width: 8),
          AppFilterChip(
            label: 'برنامه',
            activeLabel: filter.hasProgram == true
                ? 'دارای برنامه'
                : 'بدون برنامه',
            isActive: filter.hasProgram != null,
            onTap: () => MultiSelectBottomSheet.show<bool>(
              context: context,
              title: 'فیلتر بر اساس برنامه',
              options: const [true, false],
              labelBuilder: (v) => v ? 'دارای برنامه' : 'بدون برنامه',
              initialSelected: filter.hasProgram == null
                  ? []
                  : [filter.hasProgram!],
              singleSelect: true,
              onApply: (s) => onChanged(
                s.isEmpty
                    ? filter.copyWith(clearHasProgram: true)
                    : filter.copyWith(hasProgram: s.first),
              ),
            ),
            onClear: () => onChanged(filter.copyWith(clearHasProgram: true)),
          ),
          const SizedBox(width: 8),
          AppFilterChip(
            label: 'مرتب‌سازی',
            activeLabel: filter.order.label,
            isActive: filter.order != AthleteOrder.nameAsc,
            onTap: () => MultiSelectBottomSheet.show<AthleteOrder>(
              context: context,
              title: 'مرتب‌سازی',
              options: AthleteOrder.values,
              labelBuilder: (o) => o.label,
              initialSelected: [filter.order],
              singleSelect: true,
              onApply: (s) => onChanged(
                filter.copyWith(
                  order: s.isEmpty ? AthleteOrder.nameAsc : s.first,
                ),
              ),
            ),
            onClear: () =>
                onChanged(filter.copyWith(order: AthleteOrder.nameAsc)),
          ),
        ],
      ),
    );
  }
}
