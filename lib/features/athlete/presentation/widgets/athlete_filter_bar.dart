import 'package:coach_studio/core/theme/app_colors.dart';
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
          _FilterChip(
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
          _FilterChip(
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
          _FilterChip(
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

class _FilterChip extends StatelessWidget {
  final String label;
  final String activeLabel;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _FilterChip({
    required this.label,
    required this.activeLabel,
    required this.isActive,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.outline,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isActive ? '$label : $activeLabel' : label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.primaryDark : AppColors.textPrimary,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
