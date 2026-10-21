import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/display/app_info_chip.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AthleteCard extends StatelessWidget {
  final Athlete athlete;
  final VoidCallback? onTap;
  const AthleteCard({super.key, this.onTap, required this.athlete});

  @override
  Widget build(BuildContext context) {
    final programTitle = athlete.currentAssignment?.program?.title;
    final phone = athlete.phone;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: AppSurface(
        onTap: onTap,
        child: Row(
          children: [
            const _AthleteAvatar(),
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
                          athlete.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      AppInfoChip.plain(
                        text: athlete.isArchived ? 'بایگانی' : 'فعال',
                        backgroundColor: athlete.isArchived
                            ? AppColors.warningSoft
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedTask01,
                        size: 16,
                        color: AppColors.secondary,
                        strokeWidth: 2,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          programTitle ?? 'بدون برنامه',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  if (phone != null && phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            phone.persianNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AthleteAvatar extends StatelessWidget {
  const _AthleteAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.lg - 2),
        border: Border.all(color: AppColors.outline),
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 34,
        color: AppColors.primary,
      ),
    );
  }
}
