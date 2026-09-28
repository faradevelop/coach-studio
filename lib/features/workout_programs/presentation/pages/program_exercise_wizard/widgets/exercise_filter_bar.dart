import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/multi_select_bottom_sheet.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise_filter.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';
import 'package:coach_studio/features/exercises/domain/enums/difficulty.dart';
import 'package:coach_studio/features/exercises/domain/enums/equipment.dart';
import 'package:coach_studio/features/exercises/domain/enums/exercise_type.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_filter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Horizontal, RTL-safe, scrollable row of filter chips shown under the
/// exercise search field. Each chip opens [MultiSelectBottomSheet] for one
/// filter dimension and reflects the APPLIED [ExerciseFilter] held by
/// [ExerciseFilterCubit].
class ExerciseFilterBar extends StatelessWidget {
  final List<Muscle> availableMuscles;

  const ExerciseFilterBar({super.key, required this.availableMuscles});

  String? _summaryLabel(List<String> values) {
    if (values.isEmpty) return null;
    if (values.length == 1) return values.first;
    return '${values.first} +${values.length - 1}';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExerciseFilterCubit>();

    return BlocBuilder<ExerciseFilterCubit, ExerciseFilter>(
      builder: (context, filter) {
        return SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _FilterChip(
                label: 'عضله',
                activeLabel: _summaryLabel(
                  filter.muscles.map((m) => m.name).toList(),
                ),
                isActive: filter.muscles.isNotEmpty,
                onTap: () => MultiSelectBottomSheet.show<Muscle>(
                  context: context,
                  title: 'فیلتر بر اساس عضله',
                  options: availableMuscles,
                  labelBuilder: (m) => m.name,
                  initialSelected: filter.muscles,
                  onApply: cubit.applyMuscles,
                ),
                onClear: cubit.clearMuscles,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'وسیله',
                activeLabel: filter.equipment?.label,
                isActive: filter.equipment != null,
                onTap: () => MultiSelectBottomSheet.show<Equipment>(
                  context: context,
                  title: 'فیلتر بر اساس وسیله',
                  options: Equipment.values,
                  labelBuilder: (e) => e.label,
                  initialSelected: filter.equipment == null
                      ? []
                      : [filter.equipment!],
                  singleSelect: true,
                  onApply: (s) =>
                      cubit.applyEquipment(s.isEmpty ? null : s.first),
                ),
                onClear: cubit.clearEquipment,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'سطح',
                activeLabel: filter.difficulty?.label,
                isActive: filter.difficulty != null,
                onTap: () => MultiSelectBottomSheet.show<Difficulty>(
                  context: context,
                  title: 'فیلتر بر اساس سطح',
                  options: Difficulty.values,
                  labelBuilder: (d) => d.label,
                  initialSelected: filter.difficulty == null
                      ? []
                      : [filter.difficulty!],
                  singleSelect: true,
                  onApply: (selected) => cubit.applyDifficulty(
                    selected.isEmpty ? null : selected.first,
                  ),
                ),
                onClear: cubit.clearDifficulty,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: 'نوع تمرین',
                activeLabel: filter.type?.label,
                isActive: filter.type != null,
                onTap: () => MultiSelectBottomSheet.show<ExerciseType>(
                  context: context,
                  title: 'فیلتر بر اساس نوع تمرین',
                  options: ExerciseType.values,
                  labelBuilder: (t) => t.label,
                  initialSelected: filter.type == null ? [] : [filter.type!],
                  singleSelect: true,
                  onApply: (selected) =>
                      cubit.applyType(selected.isEmpty ? null : selected.first),
                ),
                onClear: cubit.clearType,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? activeLabel;
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
        padding: EdgeInsetsDirectional.only(
          end: 14,
          start: isActive ? 6 : 14,
          top: 8,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.orange.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.orange : AppColors.glassBorder,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isActive ? '$label: $activeLabel' : label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.orangeDark : AppColors.charcoal,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.orange,
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
