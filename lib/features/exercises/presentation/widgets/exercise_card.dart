import 'dart:ui';

import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 108,
            decoration: BoxDecoration(
              color: AppColors.surfaceGlass,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(
                color: AppColors.surfaceGlassBorder,
                width: 1.1,
              ),
            ),
            child: Padding(
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
                        Text(
                          exercise.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise.targetMuscle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.fireFlameCurved,
                              size: 14,
                              color: AppColors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              exercise.equipment,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.bar_chart,
                              size: 15,
                              color: AppColors.orange,
                            ),

                            Text(
                              exercise.difficulty,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Align(
                    alignment: Alignment.topRight,
                    child: MiniButton(
                      color: AppColors.charcoalSoft.withValues(alpha: 0.18),
                      icon: Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: AppColors.charcoal.withValues(alpha: 0.9),
                      ),
                      onPressed: onEdit,
                    ),
                  ),
                  SizedBox(width: 4),
                  Align(
                    alignment: Alignment.topRight,
                    child: MiniButton(
                      color: AppColors.error.withValues(alpha: 0.18),
                      icon: Icon(
                        Icons.delete_rounded,
                        size: 16,
                        color: AppColors.error.withValues(alpha: 0.9),
                      ),
                      onPressed: onDelete,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseImage extends StatelessWidget {
  final String imageUrl;

  const _ExerciseImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.2,
            ),
          ),
          child: imageUrl.isEmpty
              ? const Icon(
                  Icons.fitness_center_rounded,
                  size: 30,
                  color: AppColors.orange,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.fitness_center_rounded,
                      size: 30,
                      color: AppColors.orange,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
