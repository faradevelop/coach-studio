import 'dart:ui';

import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_configuration_args.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_error_state.dart';
import 'package:coach_studio/core/widgets/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/delete_dialog.dart';
import 'package:coach_studio/features/workout_programs/data/services/workout_program_pdf_generator.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/athlete_info.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_draft.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_details.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/athlete_info_form_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:printing/printing.dart';
import 'package:reorderables/reorderables.dart';

class WorkoutProgramDetailPage extends StatefulWidget {
  final WorkoutProgram program;

  const WorkoutProgramDetailPage({super.key, required this.program});

  @override
  State<WorkoutProgramDetailPage> createState() =>
      _WorkoutProgramDetailPageState();
}

class _WorkoutProgramDetailPageState extends State<WorkoutProgramDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ProgramExerciseCubit>().loadExercises(widget.program.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
      builder: (context, state) {
        var currentProgram = widget.program;

        if (state case WorkoutProgramLoaded(:final programs)) {
          currentProgram = programs.firstWhere(
            (program) => program.id == widget.program.id,
            orElse: () => widget.program,
          );
        }

        return _WorkoutProgramDetailView(program: currentProgram);
      },
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
      backgroundColor: AppColors.cream,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.bgColors,
            stops: AppColors.bgStops,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              InnerPagesAppBar(
                rightButton: _PdfButton(
                  enabled: !_isGeneratingPdf,
                  onTap: () => _generatePdf(context),
                ),
                title: widget.program.title,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 8, bottom: 32),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgramInfoCard(BuildContext context) {
    return _GlassCard(
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
                color: AppColors.charcoalSoft.withValues(alpha: 0.18),
                icon: Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: AppColors.charcoal.withValues(alpha: 0.9),
                ),
                onPressed: () {
                  context.pushNamed(
                    AppRouteNames.createWorkoutProgram,
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
              _InfoChip(
                icon: Icons.flag_rounded,
                text: widget.program.goal.label,
              ),
              _InfoChip(
                icon: Icons.bar_chart_rounded,
                text: widget.program.level.label,
              ),
              _InfoChip(
                icon: Icons.calendar_month_rounded,
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x30FF6500),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              CupertinoIcons.add,
              color: Colors.white,
              size: 22,
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

            ProgramExerciseError(:final message) => AppErrorState(),

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

class _DayExercisesTabs extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox();

    final exercises = exercisesByDay[selectedDay] ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDayTabs(),
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

  Widget _buildDayTabs() {
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
          children: [
            for (int i = 0; i < days.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _DayTab(
                day: days[i],
                isSelected: days[i] == selectedDay,
                onTap: () => onDayChanged(days[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayExercises(
    BuildContext context,
    List<ProgramExerciseDetails> exercises,
  ) {
    return ReorderableColumn(
      key: ValueKey(selectedDay),
      ignorePrimaryScrollController: true,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      needsLongPressDraggable: !isSubmitting,
      onReorder: (oldIndex, newIndex) {
        if (isSubmitting || oldIndex == newIndex) return;

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
          program: program,
        );
      }).toList(),
    );
  }
}

class _DayTab extends StatelessWidget {
  final int day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayTab({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.teal
              : Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.tealMuted : AppColors.glassBorder,
            width: 1.4,
          ),
          boxShadow: isSelected
              ? null
              : [
                  BoxShadow(
                    color: AppColors.charcoal.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: isSelected
                ? AppColors.onOrange
                : AppColors.charcoal.withValues(alpha: 0.78),
          ),
          child: Text('روز $day'),
        ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glass),
      ),
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
    );
  }

  Widget _buildHeader(BuildContext context, dynamic programExercise) {
    return Row(
      children: [
        Expanded(
          child: Text(
            programExercise.order.toString(),
            style: AppTextStyles.label.copyWith(fontSize: 14.5),
          ),
        ),
        Text(
          '${programExercise.sets} ست • ${programExercise.rest} استراحت',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.charcoal.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(width: 12),
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

    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      iconSize: 18,
      color: AppColors.cream,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      child: const Icon(
        Icons.more_horiz_rounded,
        size: 20,
        color: AppColors.charcoal,
      ),
    );
  }

  void _editExercise(BuildContext context, dynamic programExercise) {
    context.pushNamed(
      AppRouteNames.editProgramExercise,
      pathParameters: {
        'programId': program.id,
        'programExerciseId': programExercise.id,
      },
      extra: ProgramExerciseConfigurationArgs(
        program: program,
        draft: ProgramExerciseDraft(
          programId: program.id,
          day: programExercise.day,
          trainingSystem: programExercise.trainingSystem,
        ),
        exercises: details.items.map((item) => item.exercise).toList(),
        existingExercise: programExercise,
      ),
    );
  }

  Future<void> _deleteExercise(
    BuildContext context,
    dynamic programExercise,
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
  final dynamic itemDetails;

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
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  exercise.name,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                ),
              ),
              Text('${item.reps} تکرار •', style: AppTextStyles.bodySmall),
              const SizedBox(width: 10),
              Text(
                '${item.tempo} تمپو',
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (hasDescription) ...[
            Divider(
              color: AppColors.orange.withValues(alpha: 0.35),
              height: 12,
              thickness: 1,
            ),
            Text(
              item.description ?? '',
              style: AppTextStyles.body.copyWith(fontSize: 13.5),
              maxLines: 3,
            ),
          ],
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
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.glassBorderSoft),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.picture_as_pdf_rounded,
          size: 22,
          color: AppColors.charcoal,
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
      color: AppColors.orange,
      size: 40,
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.glassBorder, width: 1.1),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.teal),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(width: 3),
        ],
      ),
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
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    size: 30,
                    color: AppColors.orange,
                  ),
                ),
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
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.flickr(
              leftDotColor: AppColors.orange,
              rightDotColor: AppColors.charcoal,
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
