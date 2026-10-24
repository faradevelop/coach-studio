import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_summary.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_cubit.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_state.dart';
import 'package:coach_studio/features/dashboard/domain/entities/programs_summary.dart';
import 'package:coach_studio/features/dashboard/presentation/widgets/dashboard_stat_card.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class DashboardStatsSection extends StatelessWidget {
  const DashboardStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ProgramsStatCard(
            label: 'کل برنامه‌ها',
            icon: HugeIcons.strokeRoundedClipboard,
            color: AppColors.primary,
            select: (summary) => summary.total,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ProgramsStatCard(
            label: '‌برنامه‌های پیش‌نویس',
            icon: HugeIcons.strokeRoundedCopy02,
            color: AppColors.accent,
            select: (summary) => summary.templates,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AthleteStatCard(
            label: 'ورزشکارها',
            icon: HugeIcons.strokeRoundedWorkoutRun,
            color: AppColors.secondary,
            select: (summary) => summary.total,
          ),
        ),
      ],
    );
  }
}

Widget _statIcon(dynamic icon, Color color) =>
    HugeIcon(icon: icon, size: 20, color: color, strokeWidth: 2);

class _ProgramsStatCard extends StatelessWidget {
  final String label;
  final dynamic icon;
  final Color color;
  final int Function(ProgramsSummary summary) select;

  const _ProgramsStatCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.select,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
      builder: (context, state) {
        final cubit = context.read<WorkoutProgramCubit>();
        final statIcon = _statIcon(icon, color);

        return switch (state) {
          WorkoutProgramLoaded(:final programs) => DashboardStatCard(
            icon: statIcon,
            iconContainerColor: color,
            label: label,
            value: select(ProgramsSummary.fromPrograms(programs)),
            onTap: () => context.goNamed(AppRouteNames.workoutProgramsList),
          ),
          WorkoutProgramError() => DashboardStatCard(
            icon: statIcon,
            iconContainerColor: color,
            label: label,
            hasError: true,
            onTap: () => cubit.loadPrograms(),
          ),
          WorkoutProgramInitial() ||
          WorkoutProgramLoading() => DashboardStatCard(
            icon: statIcon,
            iconContainerColor: color,
            label: label,
            isLoading: true,
            onTap: null,
          ),
        };
      },
    );
  }
}

class _AthleteStatCard extends StatelessWidget {
  final String label;
  final dynamic icon;
  final Color color;
  final int Function(AthleteSummary summary) select;

  const _AthleteStatCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.select,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AthleteCubit, AthleteState>(
      builder: (context, state) {
        final cubit = context.read<AthleteCubit>();
        final statIcon = _statIcon(icon, color);

        return switch (state) {
          AthleteLoaded(:final athletes) => DashboardStatCard(
            icon: statIcon,
            iconContainerColor: color,
            label: label,
            value: select(AthleteSummary.fromAthletes(athletes)),
            onTap: () => context.goNamed(AppRouteNames.athletes),
          ),
          AthleteError() => DashboardStatCard(
            icon: statIcon,
            iconContainerColor: color,
            label: label,
            hasError: true,
            onTap: () => cubit.loadAthletes(),
          ),
          AthleteInitial() || AthleteLoading() => DashboardStatCard(
            icon: statIcon,
            iconContainerColor: color,
            label: label,
            isLoading: true,
            onTap: null,
          ),
        };
      },
    );
  }
}
