import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
import 'package:coach_studio/core/widgets/feedback/app_loading_indicator.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_detail/program_exercise_grouping.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'day_exercises_tabs.dart';

/// Reacts to [ProgramExerciseCubit] and renders loading / error / the
/// day tabs with their exercises.
class ProgramExercisesView extends StatelessWidget {
  final WorkoutProgram program;
  final int selectedDay;
  final ValueChanged<int> onDayChanged;
  final ScrollController? scrollController;

  const ProgramExercisesView({
    super.key,
    required this.program,
    required this.selectedDay,
    required this.onDayChanged,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramExerciseCubit, ProgramExerciseState>(
      builder: (context, state) {
        return switch (state) {
          ProgramExerciseLoading() => const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: AppLoadingIndicator()),
          ),
          ProgramExerciseError() => AppErrorState(
            onRetry: () =>
                context.read<ProgramExerciseCubit>().loadExercises(program.id),
          ),
          ProgramExerciseLoaded(:final exercises, :final isSubmitting) =>
            _buildTabs(exercises.groupByDay(program.daysPerWeek), isSubmitting),
          _ => const SizedBox(),
        };
      },
    );
  }

  Widget _buildTabs(
    Map<int, List<ProgramExerciseDetails>> grouped,
    bool isSubmitting,
  ) {
    return DayExercisesTabs(
      days: grouped.keys.toList()..sort(),
      exercisesByDay: grouped,
      selectedDay: selectedDay,
      onDayChanged: onDayChanged,
      program: program,
      isSubmitting: isSubmitting,
      scrollController: scrollController,
    );
  }
}
