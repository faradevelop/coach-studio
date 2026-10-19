import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
    //final summary = ProgramsSummary.fromPrograms(programs);
    final preview = programs.take(previewCount).toList();

    return AppSurface(
      padding: EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 16, 2),
            child: DashboardSectionHeader(
              title: 'برنامه های اخیر',
              actionLabel: preview.isNotEmpty ? 'مشاهده همه' : null,
              onAction: () =>
                  context.goNamed(AppRouteNames.workoutProgramsList),
            ),
          ),
          Divider(),
          for (final program in preview) ...[
            _ProgramTile(program: program),
            if (program != preview.last) Divider(indent: 76, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _ProgramTile extends StatelessWidget {
  final WorkoutProgram program;

  const _ProgramTile({required this.program});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      onTap: () => context.pushNamed(
        AppRouteNames.workoutProgramDetail,
        pathParameters: {'programId': program.id},
        extra: program,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentSoft,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedTask01,
                color: AppColors.accent,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            program.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (program.isTemplate)
                          AppInfoChip.plain(text: 'پیش نویس'),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textPrimary.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedCalendar03,
                          size: 17,
                          color: AppColors.secondary,
                          strokeWidth: 2,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          program.title,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
