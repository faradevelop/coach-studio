import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_mini_button.dart';
import 'package:coach_studio/core/widgets/display/app_info_chip.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class ProgramInfoCard extends StatelessWidget {
  final WorkoutProgram program;

  const ProgramInfoCard({super.key, required this.program});

  void _edit(BuildContext context) {
    context.pushNamed(
      AppRouteNames.createWorkoutProgram,
      queryParameters: {'programId': program.id},
      extra: program,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  program.title,
                  style: AppTextStyles.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppMiniButton(
                color: AppColors.accent.withValues(alpha: 0.2),
                onTap: () => _edit(context),
                icon: Padding(
                  padding: const EdgeInsets.all(4.5),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedEdit03,
                    size: 10,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(HugeIcons.strokeRoundedTarget02, program.goal.label),
              _InfoChip(HugeIcons.strokeRoundedLowSignal, program.level.label),
              _InfoChip(
                HugeIcons.strokeRoundedCalendar03,
                '${program.daysPerWeek} روز در هفته',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final List<List<dynamic>> icon;
  final String text;

  const _InfoChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return AppInfoChip(
      icon: HugeIcon(
        icon: icon,
        size: 15,
        color: AppColors.secondary,
        strokeWidth: 2,
      ),
      text: text,
    );
  }
}
