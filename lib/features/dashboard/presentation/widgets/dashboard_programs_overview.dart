import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
import 'package:coach_studio/core/widgets/display/app_info_chip.dart';
import 'package:coach_studio/features/dashboard/domain/entities/programs_summary.dart';
import 'package:coach_studio/features/dashboard/presentation/widgets/dashboard_glass_card.dart';
import 'package:coach_studio/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DashboardProgramsOverview extends StatelessWidget {
  const DashboardProgramsOverview({super.key});

  static const int _previewCount = 3;

  void _openAll(BuildContext context) =>
      context.goNamed(AppRouteNames.workoutProgramsList);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
      builder: (context, state) {
        final hasPrograms =
            state is WorkoutProgramLoaded && state.programs.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DashboardSectionHeader(
              title: 'برنامه‌ها',
              actionLabel: hasPrograms ? 'مشاهده همه' : null,
              onAction: hasPrograms ? () => _openAll(context) : null,
            ),
            const SizedBox(height: 12),
            switch (state) {
              WorkoutProgramInitial() ||
              WorkoutProgramLoading() => const _OverviewLoading(),
              WorkoutProgramError() => AppErrorState(
                onRetry: () =>
                    context.read<WorkoutProgramCubit>().loadPrograms(),
              ),
              WorkoutProgramLoaded(:final programs) =>
                programs.isEmpty
                    ? const _OverviewEmpty()
                    : _OverviewContent(
                        programs: programs,
                        previewCount: _previewCount,
                      ),
            },
          ],
        );
      },
    );
  }
}

class _OverviewLoading extends StatelessWidget {
  const _OverviewLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: LoadingAnimationWidget.hexagonDots(
          color: AppColors.primary,
          size: 40,
        ),
      ),
    );
  }
}

class _OverviewEmpty extends StatelessWidget {
  const _OverviewEmpty();

  @override
  Widget build(BuildContext context) {
    return DashboardGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedClipboard,
            size: 36,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Text('برنامه‌ای وجود ندارد!', style: AppTextStyles.titleMedium),
          const SizedBox(height: 6),
          Text(
            'با «ایجاد برنامه» اولین برنامه را بسازید',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }
}

class _OverviewContent extends StatelessWidget {
  final List<WorkoutProgram> programs;
  final int previewCount;

  const _OverviewContent({required this.programs, required this.previewCount});

  @override
  Widget build(BuildContext context) {
    final summary = ProgramsSummary.fromPrograms(programs);
    final preview = programs.take(previewCount).toList();

    return DashboardGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CompositionBar(summary: summary),
          const SizedBox(height: 16),
          for (final program in preview) _ProgramTile(program: program),
        ],
      ),
    );
  }
}

class _CompositionBar extends StatelessWidget {
  final ProgramsSummary summary;

  const _CompositionBar({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                if (summary.templates > 0)
                  Expanded(
                    flex: summary.templates,
                    child: const ColoredBox(color: AppColors.secondary),
                  ),
                if (summary.regular > 0)
                  Expanded(
                    flex: summary.regular,
                    child: const ColoredBox(color: AppColors.primary),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _LegendItem(
              color: AppColors.secondary,
              label: 'قالب‌ها',
              value: summary.templates,
            ),
            const SizedBox(width: 16),
            _LegendItem(
              color: AppColors.primary,
              label: 'برنامه‌های عادی',
              value: summary.regular,
            ),
          ],
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ${value.persianNumber}',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 12,
            color: AppColors.textPrimary.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

class _ProgramTile extends StatelessWidget {
  final WorkoutProgram program;

  const _ProgramTile({required this.program});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(12);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surfaceVariant,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: () => context.pushNamed(
            AppRouteNames.workoutProgramDetail,
            pathParameters: {'programId': program.id},
            extra: program,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          AppInfoChip(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedTarget02,
                              size: 14,
                              color: AppColors.secondary,
                              strokeWidth: 2,
                            ),
                            text: program.goal.label,
                          ),
                          AppInfoChip(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedLowSignal,
                              size: 14,
                              color: AppColors.secondary,
                              strokeWidth: 2,
                            ),
                            text: program.level.label,
                          ),
                          AppInfoChip(
                            icon: HugeIcon(
                              icon: HugeIcons.strokeRoundedCalendar03,
                              size: 14,
                              color: AppColors.secondary,
                              strokeWidth: 2,
                            ),
                            text: '${program.daysPerWeek} روز در هفته',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textPrimary.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
