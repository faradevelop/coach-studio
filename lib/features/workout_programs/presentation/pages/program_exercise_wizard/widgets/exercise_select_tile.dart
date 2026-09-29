import 'dart:ui';

import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/exercise_card.dart';
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg - 4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.teal.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(AppRadius.lg - 4),
            border: Border.all(
              color: isSelected
                  ? AppColors.teal.withValues(alpha: 0.6)
                  : AppColors.glassBorder,
              width: isSelected ? 1.5 : 1.1,
            ),
          ),
          child: Row(
            children: [
              _SelectionIndicator(isSelected: isSelected),
              const SizedBox(width: 14),
              Expanded(child: _ExerciseInfo(exercise: exercise)),
            ],
          ),
        ),
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
        color: isSelected
            ? AppColors.teal
            : Colors.white.withValues(alpha: 0.5),
        border: Border.all(
          color: isSelected
              ? AppColors.teal
              : AppColors.charcoal.withValues(alpha: 0.3),
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
              color: AppColors.teal,
              strokeWidth: 2,
            ),
            const SizedBox(width: 4),

            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: exercise.targetMuscles.map((muscle) {
                  return InfoChip(text: muscle.name);
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
