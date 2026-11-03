import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/widgets/dialogs/delete_dialog.dart';
import 'package:coach_studio/core/widgets/display/app_reorderable.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'day_tabs_bar.dart';
import 'empty_day_exercises.dart';
import 'program_exercise_card.dart';

/// Day tabs + the selected day's (reorderable) exercises. Owns the day
/// management flows (add / delete / reorder) and the local "managing"
/// mode flag; it never holds cubit state itself.
class DayExercisesTabs extends StatefulWidget {
  final List<int> days;
  final Map<int, List<ProgramExerciseDetails>> exercisesByDay;
  final int selectedDay;
  final ValueChanged<int> onDayChanged;
  final WorkoutProgram program;
  final bool isSubmitting;

  const DayExercisesTabs({
    super.key,
    required this.days,
    required this.exercisesByDay,
    required this.selectedDay,
    required this.onDayChanged,
    required this.program,
    required this.isSubmitting,
  });

  @override
  State<DayExercisesTabs> createState() => _DayExercisesTabsState();
}

class _DayExercisesTabsState extends State<DayExercisesTabs> {
  /// Local UI-only flag: whether the day tabs are in drag/delete mode.
  bool _isManagingDays = false;

  void _enterEditMode() {
    if (_isManagingDays) return;
    setState(() => _isManagingDays = true);
  }

  void _exitEditMode() {
    if (!_isManagingDays) return;
    setState(() => _isManagingDays = false);
  }

  Future<void> _addDay() async {
    final cubit = context.read<WorkoutProgramCubit>();

    final success = await cubit.addDay(widget.program.id);

    if (!mounted) return;

    if (!success) {
      sl<AppNotification>().error('افزودن روز ناموفق بود.');
      return;
    }

    sl<AppNotification>().success('روز جدید اضافه شد.');
  }

  Future<void> _confirmDeleteDay(int day) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteDialog(
        itemName: '',
        title: 'روز ${day.persianNumber}',
        message:
            'با حذف روز ${day.persianNumber}، تمام تمرین‌های ثبت‌ شده برای این روز نیز حذف خواهند شد. آیا مطمئن هستید؟',
      ),
    );

    if (result != true || !mounted) return;

    final workoutProgramCubit = context.read<WorkoutProgramCubit>();
    final programExerciseCubit = context.read<ProgramExerciseCubit>();

    final success = await workoutProgramCubit.deleteDay(widget.program.id, day);

    if (!mounted) return;

    if (!success) {
      sl<AppNotification>().error('حذف روز ناموفق بود.');
      return;
    }

    sl<AppNotification>().success('روز با موفقیت حذف شد.');

    // The Backend cascaded-deleted this day's ProgramExercises and shifted
    // later days down, so the exercise list must be resynced too.
    programExerciseCubit.loadExercises(widget.program.id);
  }

  Future<void> _reorderDay(int oldIndex, int newIndex) async {
    if (oldIndex == newIndex) return;

    final workoutProgramCubit = context.read<WorkoutProgramCubit>();
    final state = workoutProgramCubit.state;

    if (state is! WorkoutProgramLoaded || state.isSubmitting) return;

    final day = widget.days[oldIndex];
    // Backend expects a 1-based target position within the day sequence.
    final targetPosition = newIndex + 1;

    final success = await workoutProgramCubit.reorderDay(
      widget.program.id,
      day,
      targetPosition,
    );

    if (!mounted) return;

    if (!success) {
      sl<AppNotification>().error('جابجایی روز ناموفق بود.');
      return;
    }

    // Day <-> exercise mapping changed on the Backend; resync exercises.
    context.read<ProgramExerciseCubit>().loadExercises(widget.program.id);
  }

  void _reorderExercise(
    List<ProgramExerciseDetails> exercises,
    int oldIndex,
    int newIndex,
  ) {
    if (widget.isSubmitting || oldIndex == newIndex) return;

    final exercise = exercises[oldIndex].programExercise;
    context.read<ProgramExerciseCubit>().reorderProgramExercise(
      exercise.id,
      newIndex + 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.days.isEmpty) return const SizedBox();

    final exercises = widget.exercisesByDay[widget.selectedDay] ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DayTabsBar(
          days: widget.days,
          selectedDay: widget.selectedDay,
          isManaging: _isManagingDays,
          onDaySelected: widget.onDayChanged,
          onEnterManaging: _enterEditMode,
          onExitManaging: _exitEditMode,
          onAddDay: _addDay,
          onDeleteDay: _confirmDeleteDay,
          onReorderDay: _reorderDay,
        ),
        const SizedBox(height: 18),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                alignment: Alignment.topRight,
                child: child,
              ),
            ),
            child: exercises.isEmpty
                ? const EmptyDayExercises(key: ValueKey('empty-day'))
                : _buildExercisesColumn(exercises),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesColumn(List<ProgramExerciseDetails> exercises) {
    return AppReorderableColumn(
      key: ValueKey(widget.selectedDay),
      ignorePrimaryScrollController: true,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      needsLongPressDraggable: !widget.isSubmitting,
      onReorder: (oldIndex, newIndex) =>
          _reorderExercise(exercises, oldIndex, newIndex),
      children: [
        for (final details in exercises)
          ProgramExerciseCard(
            key: ValueKey(details.programExercise.id),
            details: details,
            program: widget.program,
          ),
      ],
    );
  }
}
