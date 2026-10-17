import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_surface.dart';
import 'package:coach_studio/core/widgets/app_info_chip.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ExerciseSelectTile extends StatelessWidget {
  final Exercise exercise;
  final bool isSelected;

  const ExerciseSelectTile({
    super.key,
    required this.exercise,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Tap handling stays with the caller (GestureDetector in the list).
    return AppSurface(
      selected: isSelected,
      elevated: false,
      radius: AppRadius.lg - 4,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          _SelectionIndicator(isSelected: isSelected),
          const SizedBox(width: 14),
          Expanded(child: _ExerciseInfo(exercise: exercise)),
        ],
      ),
    );
  }
}

class _SelectionIndicator extends StatelessWidget {
  final bool isSelected;

  const _SelectionIndicator({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.secondary : AppColors.surface,
        border: Border.all(
          color: isSelected ? AppColors.secondary : AppColors.disabled,
          width: 1.4,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
          : null,
    );
  }
}

class _ExerciseInfo extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseInfo({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exercise.name,
          style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedFire02,
              size: 14,
              color: AppColors.secondary,
              strokeWidth: 2,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: exercise.targetMuscles.map((muscle) {
                  return AppInfoChip.plain(text: muscle.name);
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
