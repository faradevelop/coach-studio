import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/display/app_info_chip.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/features/athlete/domain/athlete.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AthleteCard extends StatelessWidget {
  final Athlete athlete;
  final VoidCallback? onTap;
  const AthleteCard({super.key, this.onTap, required this.athlete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: AppSurface(
        onTap: onTap,
        child: Row(
          children: [
            _AthleteImage(imageUrl: ''),
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
                          'سارا',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ),

                      AppInfoChip.plain(text: 'فعال'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedDateTime,
                        size: 16,
                        color: AppColors.secondary,
                        strokeWidth: 2,
                      ),
                      SizedBox(width: 6),
                      Text(
                        '29-01-1405',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
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

class _AthleteImage extends StatelessWidget {
  final String imageUrl;

  const _AthleteImage({required this.imageUrl});

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
