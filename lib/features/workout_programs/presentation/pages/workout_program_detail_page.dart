import 'dart:ui' show PointerDeviceKind;

import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_shadows.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/dialogs/app_dialog.dart';
import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/core/widgets/navigation/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/dialogs/delete_dialog.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/core/widgets/display/app_info_chip.dart';
import 'package:coach_studio/features/workout_programs/data/services/workout_program_pdf_generator.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/athlete_info.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_details.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/athlete_info_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:printing/printing.dart';
import 'package:reorderables/reorderables.dart';

class WorkoutProgramDetailPage extends StatefulWidget {
  final String programId;
  final WorkoutProgram? seedProgram; // optional fast path only

  const WorkoutProgramDetailPage({
    super.key,
    required this.programId,
    this.seedProgram,
  });

  @override
  State<WorkoutProgramDetailPage> createState() =>
      _WorkoutProgramDetailPageState();
}

class _WorkoutProgramDetailPageState extends State<WorkoutProgramDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProgramExerciseCubit>().loadExercises(widget.programId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
      builder: (context, state) {
        WorkoutProgram? currentProgram = widget.seedProgram;

        if (state case WorkoutProgramLoaded(:final programs)) {
          for (final p in programs) {
            if (p.id == widget.programId) {
              currentProgram = p;
              break;
            }
          }
        }

        if (currentProgram == null) {
          // Distinguish "list still loading" from "genuinely not found"
          // (e.g. deleted elsewhere, or a stale bookmark) instead of
          // spinning forever either way.
          if (state is WorkoutProgramLoaded) {
            return _ProgramNotFoundState();
          }
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: _DetailLoadingIndicator()),
          );
        }

        return _WorkoutProgramDetailView(program: currentProgram);
      },
    );
  }
}

class _DetailLoadingIndicator extends StatelessWidget {
  const _DetailLoadingIndicator();
  @override
  Widget build(BuildContext context) =>
      LoadingAnimationWidget.hexagonDots(color: AppColors.primary, size: 40);
}

class _ProgramNotFoundState extends StatelessWidget {
  const _ProgramNotFoundState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AppErrorState(
          title: 'برنامه‌ای یافت نشد',
          message: 'این برنامه ممکن است حذف شده باشد.',
          retryLabel: 'بازگشت به لیست برنامه‌ها',
          onRetry: () => context.goNamed(AppRouteNames.workoutProgramsList),
        ),
      ),
    );
  }
}

class _WorkoutProgramDetailView extends StatefulWidget {
  final WorkoutProgram program;

  const _WorkoutProgramDetailView({required this.program});

  @override
  State<_WorkoutProgramDetailView> createState() =>
      _WorkoutProgramDetailViewState();
}

class _WorkoutProgramDetailViewState extends State<_WorkoutProgramDetailView> {
  bool _isGeneratingPdf = false;
  int _selectedDay = 1;

  @override
  void didUpdateWidget(covariant _WorkoutProgramDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.program.id != widget.program.id) {
      _selectedDay = 1;
    }
    if (_selectedDay > widget.program.daysPerWeek) {
      _selectedDay = widget.program.daysPerWeek;
    }
  }

  Map<int, List<ProgramExerciseDetails>> _groupByDay(
    int days,
    List<ProgramExerciseDetails> exercises,
  ) {
    final groupedExercises = <int, List<ProgramExerciseDetails>>{
      for (int day = 1; day <= days; day++) day: [],
    };

    for (final exercise in exercises) {
      final day = exercise.programExercise.day;
      groupedExercises.putIfAbsent(day, () => []).add(exercise);
    }

    for (final list in groupedExercises.values) {
      list.sort(
        (a, b) => a.programExercise.order.compareTo(b.programExercise.order),
      );
    }

    return groupedExercises;
  }

  void _addExercise() {
    context.pushNamed(
      AppRouteNames.createProgramExercise,
      pathParameters: {'programId': widget.program.id},
      queryParameters: {'day': _selectedDay.toString()},
      extra: widget.program,
    );
  }

  Future<void> _generatePdf(BuildContext context) async {
    final state = context.read<ProgramExerciseCubit>().state;

    if (state is! ProgramExerciseLoaded || state.exercises.isEmpty) {
      sl<AppNotification>().warning('ابتدا تمرین ایجاد کنید!');

      return;
    }

    final athlete = await showDialog<AthleteInfo>(
      context: context,
      builder: (_) => const AthleteInfoFormDialog(),
    );

    if (athlete == null || !context.mounted) return;

    setState(() => _isGeneratingPdf = true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => const _PdfLoadingDialog(),
    );

    try {
      final details = WorkoutProgramDetails(
        program: widget.program,
        exercises: state.exercises,
      );

      final bytes = await WorkoutProgramPdfGenerator().generate(
        details: details,
        athlete: athlete,
      );

      await Printing.sharePdf(
        bytes: bytes,
        filename: '${widget.program.title}.pdf',
      );

      if (context.mounted) {
        sl<AppNotification>().success('PDF برنامه ایجاد شد!');
        context.pop();
      }
    } catch (_) {
      if (context.mounted) {
        context.pop();
        sl<AppNotification>().error('ساخت PDF با خطا مواجه شد');
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            MaxWidthBox(
              maxWidth: AppContentWidth.detail,
              child: InnerPagesAppBar(
                rightButton: _PdfButton(
                  enabled: !_isGeneratingPdf,
                  onTap: () => _generatePdf(context),
                ),
                title: widget.program.title,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8, bottom: 32),
                child: MaxWidthBox(
                  maxWidth: AppContentWidth.detail,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildProgramInfoCard(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildExercisesHeader(context),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildExercisesList(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramInfoCard(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.program.title,
                  style: AppTextStyles.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              MiniButton(
                color: AppColors.textPrimary.withValues(alpha: 0.18),
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedEdit03,
                  size: 18,
                  color: AppColors.textPrimary.withValues(alpha: 0.9),
                ),

                onPressed: () {
                  context.pushNamed(
                    AppRouteNames.createWorkoutProgram,
                    queryParameters: {'programId': widget.program.id},
                    extra: widget.program,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppInfoChip(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedTarget02,
                  size: 15,
                  color: AppColors.secondary,
                  strokeWidth: 2,
                ),
                text: widget.program.goal.label,
              ),
              AppInfoChip(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedLowSignal,
                  size: 15,
                  color: AppColors.secondary,
                  strokeWidth: 2,
                ),
                text: widget.program.level.label,
              ),
              AppInfoChip(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCalendar03,
                  size: 15,
                  color: AppColors.secondary,
                  strokeWidth: 2,
                ),
                text: '${widget.program.daysPerWeek} روز در هفته',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesHeader(BuildContext context) {
    return Row(
      children: [
        Text('تمرین‌ها', style: AppTextStyles.titleMedium),
        const Spacer(),
        GestureDetector(
          onTap: _addExercise,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.primaryGlow,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedTaskAdd01,
              size: 18,
              color: AppColors.onPrimary,
              strokeWidth: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesList(BuildContext context) {
    return BlocListener<ProgramExerciseCubit, ProgramExerciseState>(
      listenWhen: (previous, current) {
        return current is ProgramExerciseLoaded && current.errorMessage != null;
      },
      listener: (context, state) {
        if (state is ProgramExerciseLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: BlocBuilder<ProgramExerciseCubit, ProgramExerciseState>(
        builder: (context, state) {
          return switch (state) {
            ProgramExerciseLoading() => const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: _ExercisesLoadingIndicator()),
            ),

            ProgramExerciseError() => AppErrorState(
              onRetry: () => context.read<ProgramExerciseCubit>().loadExercises(
                widget.program.id,
              ),
            ),

            ProgramExerciseLoaded(:final exercises, :final isSubmitting) =>
              _buildExercisesByDay(
                context,
                widget.program.daysPerWeek,
                exercises,
                isSubmitting,
              ),

            _ => const SizedBox(),
          };
        },
      ),
    );
  }

  Widget _buildExercisesByDay(
    BuildContext context,
    int workoutDays,
    List<ProgramExerciseDetails> exercises,
    bool isSubmitting,
  ) {
    final groupedExercises = _groupByDay(workoutDays, exercises);

    return _DayExercisesTabs(
      days: groupedExercises.keys.toList()..sort(),
      exercisesByDay: groupedExercises,
      selectedDay: _selectedDay,
      onDayChanged: (day) => setState(() => _selectedDay = day),
      program: widget.program,
      isSubmitting: isSubmitting,
    );
  }
}

// ── Day tabs + list ──────────────────────────────────────────

class _DayExercisesTabs extends StatefulWidget {
  final List<int> days;
  final Map<int, List<ProgramExerciseDetails>> exercisesByDay;
  final int selectedDay;
  final ValueChanged<int> onDayChanged;
  final WorkoutProgram program;
  final bool isSubmitting;

  const _DayExercisesTabs({
    required this.days,
    required this.exercisesByDay,
    required this.selectedDay,
    required this.onDayChanged,
    required this.program,
    required this.isSubmitting,
  });

  @override
  State<_DayExercisesTabs> createState() => _DayExercisesTabsState();
}

class _DayExercisesTabsState extends State<_DayExercisesTabs> {
  /// Local UI-only flag: whether the day tabs are currently in
  /// drag/delete "management" mode. Entered via long-press on a day,
  /// exited via the done (✓) button. This never touches Cubit state.
  bool _isManagingDays = false;

  void _enterEditMode() {
    // Long-pressing a day while already managing must NOT re-trigger
    // entering edit mode — it must be free for the drag gesture instead.
    if (_isManagingDays) return;
    setState(() => _isManagingDays = true);
  }

  void _exitEditMode() {
    if (!_isManagingDays) return;
    setState(() => _isManagingDays = false);
  }

  Future<void> _addDay(BuildContext context) async {
    final cubit = context.read<WorkoutProgramCubit>();

    final success = await cubit.addDay(widget.program.id);

    if (!context.mounted) return;

    if (!success) {
      sl<AppNotification>().error('افزودن روز ناموفق بود.');
      return;
    }

    sl<AppNotification>().success('روز جدید اضافه شد.');
  }

  Future<void> _confirmDeleteDay(BuildContext context, int day) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteDialog(
        itemName: '',
        title: 'روز ${day.persianNumber}',
        message:
            'با حذف روز ${day.persianNumber}، تمام تمرین‌های ثبت‌ شده برای این روز نیز حذف خواهند شد. آیا مطمئن هستید؟',
      ),
    );

    if (result != true || !context.mounted) return;

    final workoutProgramCubit = context.read<WorkoutProgramCubit>();
    final programExerciseCubit = context.read<ProgramExerciseCubit>();

    final success = await workoutProgramCubit.deleteDay(widget.program.id, day);

    if (!context.mounted) return;

    if (!success) {
      sl<AppNotification>().error('حذف روز ناموفق بود.');
      return;
    }

    sl<AppNotification>().success('روز با موفقیت حذف شد.');

    // The Backend cascaded-deleted this day's ProgramExercises and shifted
    // later days down, so the exercise list must be resynced too.
    programExerciseCubit.loadExercises(widget.program.id);
  }

  Future<void> _reorderDay(
    BuildContext context,
    int oldIndex,
    int newIndex,
  ) async {
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

    if (!context.mounted) return;

    if (!success) {
      sl<AppNotification>().error('جابجایی روز ناموفق بود.');
      return;
    }

    // Day <-> exercise mapping changed on the Backend; resync exercises so
    // each tab shows the correct (post-reorder) content.
    context.read<ProgramExerciseCubit>().loadExercises(widget.program.id);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.days.isEmpty) return const SizedBox();

    final exercises = widget.exercisesByDay[widget.selectedDay] ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDayTabsRow(),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  alignment: Alignment.topRight,
                  child: child,
                ),
              );
            },
            child: exercises.isEmpty
                ? const _EmptyDayExercisesState(key: ValueKey('empty-day'))
                : _buildSelectedDayExercises(context, exercises),
          ),
        ),
      ],
    );
  }

  Widget _buildDayTabsRow() {
    return BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
      builder: (context, programState) {
        final isDayOperationInProgress =
            programState is WorkoutProgramLoaded && programState.isSubmitting;

        return ScrollConfiguration(
          behavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _isManagingDays
                    ? ReorderableRow(
                        needsLongPressDraggable: true,
                        onReorder: (oldIndex, newIndex) =>
                            _reorderDay(context, oldIndex, newIndex),
                        children: [
                          for (final day in widget.days)
                            Padding(
                              key: ValueKey('day-$day'),
                              padding: const EdgeInsets.only(left: 8),
                              child: _DayTab(
                                day: day,
                                isSelected: day == widget.selectedDay,
                                isManaging: true,
                                onTap: () => widget.onDayChanged(day),
                                onLongPress: null,
                                onDelete: isDayOperationInProgress
                                    ? null
                                    : () => _confirmDeleteDay(context, day),
                              ),
                            ),
                        ],
                      )
                    : Row(
                        children: [
                          for (int i = 0; i < widget.days.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            _DayTab(
                              day: widget.days[i],
                              isSelected: widget.days[i] == widget.selectedDay,
                              isManaging: false,
                              onTap: () => widget.onDayChanged(widget.days[i]),
                              onLongPress: _enterEditMode,
                              onDelete: null,
                            ),
                          ],
                        ],
                      ),
                const SizedBox(width: 8),
                if (!_isManagingDays)
                  _AddDayButton(
                    enabled: !isDayOperationInProgress,
                    onTap: () => _addDay(context),
                  ),
                if (_isManagingDays) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 6),
                    child: _DoneManagingDaysButton(onTap: _exitEditMode),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDayExercises(
    BuildContext context,
    List<ProgramExerciseDetails> exercises,
  ) {
    return ReorderableColumn(
      key: ValueKey(widget.selectedDay),
      ignorePrimaryScrollController: true,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      needsLongPressDraggable: !widget.isSubmitting,
      onReorder: (oldIndex, newIndex) {
        if (widget.isSubmitting || oldIndex == newIndex) return;

        final exercise = exercises[oldIndex].programExercise;
        context.read<ProgramExerciseCubit>().reorderProgramExercise(
          exercise.id,
          newIndex + 1,
        );
      },
      children: exercises.map((details) {
        return _ProgramExerciseCard(
          key: ValueKey(details.programExercise.id),
          details: details,
          program: widget.program,
        );
      }).toList(),
    );
  }
}

class _DayTab extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isManaging;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;

  const _DayTab({
    required this.day,
    required this.isSelected,
    required this.isManaging,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      // Passing null when already managing frees the long-press gesture
      // for the ReorderableRow's own LongPressDraggable to claim, instead
      // of this GestureDetector consuming it to re-enter edit mode.
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(top: isManaging ? 10 : 0),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: isSelected ? AppColors.primaryDark : AppColors.outline,
                  width: 1.4,
                ),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.textPrimary.withValues(alpha: 0.78),
                ),
                child: Text('روز ${day.persianNumber}'),
              ),
            ),
            if (isManaging)
              PositionedDirectional(
                top: -10,
                end: -4,
                child: GestureDetector(
                  onTap: onDelete,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.4),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddDayButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _AddDayButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? AppColors.textSecondary
        : AppColors.textSecondary.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 42,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedAdd01,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}

class _DoneManagingDaysButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DoneManagingDaysButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
      ),
    );
  }
}

// ── Exercise cards ───────────────────────────────────────────

class _ProgramExerciseCard extends StatelessWidget {
  final ProgramExerciseDetails details;
  final WorkoutProgram program;

  const _ProgramExerciseCard({
    super.key,
    required this.details,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    final programExercise = details.programExercise;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppSurface(
        radius: AppRadius.md + 2,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, programExercise),
            const SizedBox(height: 10),
            ...details.items.map(
              (itemDetails) => _ExerciseItemCard(itemDetails: itemDetails),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ProgramExercise programExercise) {
    return Row(
      children: [
        Text(
          "${programExercise.order.persianNumber} )",
          style: AppTextStyles.label.copyWith(fontSize: 14.5),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${programExercise.sets.persianNumber} ست  •   ${programExercise.rest.persianNumber} استراحت',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.75),
            ),
          ),
        ),
        _ExercisePopupMenu(program: program, details: details),
      ],
    );
  }
}

class _ExercisePopupMenu extends StatelessWidget {
  final WorkoutProgram program;
  final ProgramExerciseDetails details;

  const _ExercisePopupMenu({required this.program, required this.details});

  @override
  Widget build(BuildContext context) {
    final programExercise = details.programExercise;

    // Colour / shape / elevation come from AppTheme.popupMenuTheme.
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      iconSize: 18,
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            _editExercise(context, programExercise);
          case 'delete':
            await _deleteExercise(context, programExercise);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('ویرایش')),
        PopupMenuItem(
          value: 'delete',
          child: Text('حذف', style: TextStyle(color: AppColors.error)),
        ),
      ],
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedMoreHorizontalCircle01,
        size: 20,
        color: AppColors.primary,
      ),
    );
  }

  void _editExercise(BuildContext context, ProgramExercise programExercise) {
    context.pushNamed(
      AppRouteNames.editProgramExercise,
      pathParameters: {
        'programId': program.id,
        'programExerciseId': programExercise.id,
      },
      extra: details,
    );
  }

  Future<void> _deleteExercise(
    BuildContext context,
    ProgramExercise programExercise,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteDialog(itemName: '', title: 'تمرین'),
    );

    if (result == true && context.mounted) {
      final success = await context.read<ProgramExerciseCubit>().deleteExercise(
        programExercise.id,
      );
      if (!success) {
        sl<AppNotification>().error('حذف تمرین ناموفق بود.');
        return;
      }

      sl<AppNotification>().success('تمرین با موفقیت حذف شد.');
    }
  }
}

class _ExerciseItemCard extends StatelessWidget {
  final ProgramExerciseItemDetails itemDetails;

  const _ExerciseItemCard({required this.itemDetails});

  @override
  Widget build(BuildContext context) {
    final item = itemDetails.item;
    final exercise = itemDetails.exercise;
    final hasDescription =
        item.description != null && item.description!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: AppTextStyles.body.copyWith(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          Visibility(
            visible: hasDescription,
            child: Text(
              item.description ?? '',
              style: AppTextStyles.body.copyWith(fontSize: 12.5),
              maxLines: 3,
            ),
          ),
          Divider(
            color: AppColors.primary.withValues(alpha: 0.25),
            height: 12,
            thickness: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AppInfoChip(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedRepeat,
                  color: AppColors.secondary,
                  size: 14,
                  strokeWidth: 2,
                ),
                text: '${item.reps.join(' - ')} تکرار ',
              ),
              const SizedBox(width: 10),
              Visibility(
                visible: item.tempo != '-',
                child: AppInfoChip(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedPendulum,
                    color: AppColors.secondary,
                    size: 14,
                    strokeWidth: 2,
                  ),
                  text: '${item.tempo} تمپو ',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Shared small widgets ─────────────────────────────────────

class _PdfButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _PdfButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outline),
          boxShadow: AppShadows.card,
        ),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedPdf02,
          size: 22,
          color: AppColors.textPrimary,
          strokeWidth: 1.5,
        ),
      ),
    );
  }
}

class _ExercisesLoadingIndicator extends StatelessWidget {
  const _ExercisesLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.hexagonDots(
      color: AppColors.primary,
      size: 40,
    );
  }
}

/// Full-width card used by this page (thin wrapper over [AppSurface]).
class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

class _EmptyDayExercisesState extends StatelessWidget {
  const _EmptyDayExercisesState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 30,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'برای این روز تمرینی ثبت نشده است',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text('با دکمه + تمرین اضافه کنید', style: AppTextStyles.subtitle),
          ],
        ),
      ),
    );
  }
}

class _PdfLoadingDialog extends StatelessWidget {
  const _PdfLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      maxWidth: 260,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.flickr(
              leftDotColor: AppColors.primary,
              rightDotColor: AppColors.secondary,
              size: 42,
            ),
            const SizedBox(height: 20),
            Text(
              'در حال ساخت PDF',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('لطفاً کمی صبر کنید...', style: AppTextStyles.subtitle),
          ],
        ),
      ),
    );
  }
}
