import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/display/app_info_chip.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showActions;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: AppSurface(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: AppSpacing.md,
        ),
        child: Row(
          children: [
            _ExerciseImage(imageUrl: exercise.imageUrl ?? ''),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (showActions) ...[
                        Align(
                          alignment: Alignment.topRight,
                          child: MiniButton(
                            color: AppColors.textPrimary.withValues(
                              alpha: 0.18,
                            ),
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedEdit03,
                              size: 18,
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.9,
                              ),
                            ),
                            onPressed: onEdit,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Align(
                          alignment: Alignment.topRight,
                          child: MiniButton(
                            color: AppColors.error.withValues(alpha: 0.18),
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedDelete03,
                              size: 18,
                              color: AppColors.error.withValues(alpha: 0.9),
                            ),
                            onPressed: onDelete,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedLowSignal,
                        size: 16,
                        color: AppColors.secondary,
                        strokeWidth: 2,
                      ),
                      const SizedBox(width: 4),
                      AppInfoChip.plain(text: exercise.difficulty.label),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedFire02,
                        size: 16,
                        color: AppColors.secondary,
                        strokeWidth: 2,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (
                                var index = 0;
                                index < exercise.targetMuscles.length;
                                index++
                              ) ...[
                                if (index > 0) const SizedBox(width: 6),
                                AppInfoChip.plain(
                                  text: exercise.targetMuscles[index].name,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseImage extends StatelessWidget {
  final String imageUrl;

  const _ExerciseImage({required this.imageUrl});

  static const _placeholder = Icon(
    Icons.fitness_center_rounded,
    size: 30,
    color: AppColors.primary,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg - 2),
        border: Border.all(color: AppColors.outline),
      ),
      child: imageUrl.isEmpty
          ? _placeholder
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _placeholder,
            ),
    );
  }
}
