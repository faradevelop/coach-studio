import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/display/app_glass_surface.dart';
import 'package:coach_studio/core/widgets/display/app_info_chip.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
    return AppGlassSurface(
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
            'با کلیک روی «ساخت برنامه» اولین برنامه را بسازید',
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

  /// Icon tones cycle orange → indigo → teal, like the reference board.
  static const List<Color> _tones = [
    AppColors.primary,
    AppColors.accent,
    AppColors.secondary,
  ];

  @override
  Widget build(BuildContext context) {
    final preview = programs.take(previewCount).toList();

    return AppSurface(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: DashboardSectionHeader(
              title: 'برنامه‌های اخیر',
              icon: HugeIcon(
                icon: HugeIcons.strokeRounded24HoursClock,
                color: AppColors.primary,
                size: 21,
                strokeWidth: 2,
              ),
              actionLabel: preview.isNotEmpty ? 'مشاهده همه' : null,
              onAction: () =>
                  context.goNamed(AppRouteNames.workoutProgramsList),
            ),
          ),
          const Divider(height: 16),
          for (var i = 0; i < preview.length; i++) ...[
            _ProgramTile(program: preview[i], tone: _tones[i % _tones.length]),
            if (i < preview.length - 1)
              const Divider(indent: 78, endIndent: 16, height: 1),
          ],
        ],
      ),
    );
  }
}

class _ProgramTile extends StatelessWidget {
  final WorkoutProgram program;
  final Color tone;

  const _ProgramTile({required this.program, required this.tone});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: tone.withValues(alpha: 0.08),
      highlightColor: Colors.transparent,
      onTap: () => context.pushNamed(
        AppRouteNames.workoutProgramDetail,
        pathParameters: {'programId': program.id},
        extra: program,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.md + 2),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedTask01,
                size: 22,
                color: tone,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(width: 14),
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${program.goal.label} • ${program.daysPerWeek.persianNumber} روز در هفته',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            if (program.isTemplate) ...[
              const SizedBox(width: 8),
              AppInfoChip.plain(text: 'پیش نویس'),
            ],
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textPrimary.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
