import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/features/dashboard/domain/entities/programs_summary.dart';
import 'package:coach_studio/features/dashboard/presentation/widgets/dashboard_stat_card.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
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
      children: [
        Expanded(
          child: _ProgramsStatCard(
            label: 'برنامه‌ها',
            icon: HugeIcons.strokeRoundedTask01,
            select: (summary) => summary.total,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ProgramsStatCard(
            label: 'قالب‌ها',
            icon: HugeIcons.strokeRoundedCopy02,
            select: (summary) => summary.templates,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: _ExercisesStatCard()),
      ],
    );
  }
}

Widget _statIcon(dynamic icon) =>
    HugeIcon(icon: icon, size: 18, color: AppColors.teal, strokeWidth: 2);

class _ProgramsStatCard extends StatelessWidget {
  final String label;
  final dynamic icon;
  final int Function(ProgramsSummary summary) select;

  const _ProgramsStatCard({
    required this.label,
    required this.icon,
    required this.select,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
      builder: (context, state) {
        final cubit = context.read<WorkoutProgramCubit>();

        return switch (state) {
          WorkoutProgramLoaded(:final programs) => DashboardStatCard(
            icon: _statIcon(icon),
            label: label,
            value: select(ProgramsSummary.fromPrograms(programs)),
            onTap: () => context.goNamed(AppRouteNames.workoutProgramsList),
          ),
          WorkoutProgramError() => DashboardStatCard(
            icon: _statIcon(icon),
            label: label,
            hasError: true,
            onTap: () => cubit.loadPrograms(),
          ),
          WorkoutProgramInitial() ||
          WorkoutProgramLoading() => DashboardStatCard(
            icon: _statIcon(icon),
            label: label,
            isLoading: true,
            onTap: null,
          ),
        };
      },
    );
  }
}

class _ExercisesStatCard extends StatelessWidget {
  const _ExercisesStatCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      builder: (context, state) {
        final cubit = context.read<ExerciseCubit>();
        final icon = _statIcon(HugeIcons.strokeRoundedDumbbell01);
        const label = 'تمرین‌ها';

        if (state is ExerciseError) {
          return DashboardStatCard(
            icon: icon,
            label: label,
            hasError: true,
            onTap: () => cubit.loadExercises(),
          );
        }

        // Total of the UNFILTERED catalog (see ExerciseCubit.totalExercises);
        // null means it has not been loaded yet.
        final total = cubit.totalExercises;
        if (total == null) {
          return DashboardStatCard(
            icon: icon,
            label: label,
            isLoading: true,
            onTap: null,
          );
        }

        return DashboardStatCard(
          icon: icon,
          label: label,
          value: total,
          onTap: () => context.goNamed(AppRouteNames.exercises),
        );
      },
    );
  }
}
