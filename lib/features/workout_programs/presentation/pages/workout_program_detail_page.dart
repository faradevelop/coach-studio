import 'dart:ui';

import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_configuration_args.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:printing/printing.dart';

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

  Map<int, List<ProgramExerciseDetails>> _groupByDay(
    List<ProgramExerciseDetails> exercises,
  ) {
    final groupedExercises = <int, List<ProgramExerciseDetails>>{};

    for (final exercise in exercises) {
      groupedExercises
          .putIfAbsent(exercise.programExercise.day, () => [])
          .add(exercise);
    }

    for (final exercises in groupedExercises.values) {
      exercises.sort(
        (a, b) => a.programExercise.order.compareTo(b.programExercise.order),
      );
    }

    return groupedExercises;
  }

  Future<void> _generatePdf(BuildContext context) async {
    final state = context.read<ProgramExerciseCubit>().state;

    if (state is! ProgramExerciseLoaded || state.exercises.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ابتدا تمرین اضافه کنید')));
      return;
    }

    final athlete = await showDialog<AthleteInfo>(
      context: context,
      builder: (_) => const AthleteInfoFormDialog(),
    );

    if (athlete == null || !context.mounted) {
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
    });

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
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        context.pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ساخت PDF با خطا مواجه شد')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
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
            colors: [
              Color(0xFFFF9A5A),
              Color(0xFFFFC9A0),
              Color(0xFFFFF0E0),
              AppColors.cream,
            ],
            stops: [0.0, 0.18, 0.45, 1.0],
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
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProgramInfoCard(context),
                      const SizedBox(height: 24),
                      _buildExercisesHeader(context),
                      const SizedBox(height: 16),
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
              Text(
                widget.program.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              const Spacer(),
              MiniButton(
                color: Colors.blueAccent.withValues(alpha: 0.38),
                icon: const Icon(
                  Icons.edit,
                  size: 14,
                  color: Color.fromARGB(255, 3, 29, 157),
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
                text: widget.program.goal.name,
              ),
              _InfoChip(
                icon: Icons.bar_chart_rounded,
                text: widget.program.level.name,
              ),
              _InfoChip(
                icon: Icons.calendar_today_rounded,
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
        const Text(
          'تمرین‌ها',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            context.pushNamed(
              AppRouteNames.createProgramExercise,
              pathParameters: {'programId': widget.program.id},
              extra: widget.program,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildExercisesList(BuildContext context) {
    return BlocBuilder<ProgramExerciseCubit, ProgramExerciseState>(
      builder: (context, state) {
        return switch (state) {
          ProgramExerciseLoading() => const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: _ExercisesLoadingIndicator()),
          ),
          ProgramExerciseError(:final message) => Center(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.charcoal),
            ),
          ),
          ProgramExerciseLoaded(:final exercises) =>
            exercises.isEmpty
                ? const _EmptyExercisesState()
                : _buildExercisesByDay(context, exercises),
          _ => const SizedBox(),
        };
      },
    );
  }

  Widget _buildExercisesByDay(
    BuildContext context,
    List<ProgramExerciseDetails> exercises,
  ) {
    final groupedExercises = _groupByDay(exercises);
    final sortedDays = groupedExercises.keys.toList()..sort();

    return Column(
      children: sortedDays.map((day) {
        final dayExercises = groupedExercises[day]!;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _DayExercisesCard(
            day: day,
            exercises: dayExercises,
            program: widget.program,
          ),
        );
      }).toList(),
    );
  }
}

class _DayExercisesCard extends StatelessWidget {
  final int day;
  final List<ProgramExerciseDetails> exercises;
  final WorkoutProgram program;

  const _DayExercisesCard({
    required this.day,
    required this.exercises,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassCard(
      child: Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(top: 8),
            initiallyExpanded: true,
            iconColor: AppColors.charcoal,
            title: _buildDayTitle(),
            children: exercises.map((details) {
              return _ProgramExerciseCard(details: details, program: program);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildDayTitle() {
    return Row(
      children: [
        Container(
          width: 44,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              'روز $day',
              style: const TextStyle(
                color: AppColors.orange,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgramExerciseCard extends StatelessWidget {
  final ProgramExerciseDetails details;
  final WorkoutProgram program;

  const _ProgramExerciseCard({required this.details, required this.program});

  @override
  Widget build(BuildContext context) {
    final programExercise = details.programExercise;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dirtyCream.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
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
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
        ),
        Text(
          '${programExercise.sets} ست • ${programExercise.rest} استراحت',
          style: const TextStyle(fontSize: 12, color: AppColors.charcoal),
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
          child: Text('حذف', style: TextStyle(color: AppColors.orange)),
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
      context.read<ProgramExerciseCubit>().deleteExercise(programExercise.id);
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal,
                  ),
                  maxLines: 2,
                ),
              ),
              Text(
                '${item.reps} تکرار •',
                style: const TextStyle(fontSize: 12, color: AppColors.charcoal),
              ),
              const SizedBox(width: 10),
              Text(
                '${item.tempo}  تمپو ',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
          if (hasDescription) ...[
            Divider(
              color: AppColors.orange.withValues(alpha: 0.5),
              height: 12,
              thickness: 1,
            ),
            Text(
              item.description ?? '',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.charcoal,
              ),
              maxLines: 3,
            ),
          ],
        ],
      ),
    );
  }
}

class _PdfButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _PdfButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
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

// -------------------- Widgets --------------------

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.1,
            ),
          ),
          child: child,
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
        color: AppColors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.orange),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyExercisesState extends StatelessWidget {
  const _EmptyExercisesState();

  static const Color _charcoal = Color(0xFF2D2D2D);
  static const Color _orange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 32,
                color: _orange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تمرینی در برنامه وجود ندارد!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _charcoal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'اولین تمرین را اضافه کنید',
              style: TextStyle(
                fontSize: 13,
                color: _charcoal.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PdfLoadingDialog extends StatelessWidget {
  const _PdfLoadingDialog();

  static const Color _orange = Color(0xFFFF6B35);
  static const Color _charcoal = Color(0xFF2D2D2D);
  static const Color _cream = Color(0xFFFFF8F0);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 260,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: _cream,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.flickr(
              leftDotColor: _orange,
              rightDotColor: _charcoal,
              size: 42,
            ),
            const SizedBox(height: 20),
            const Text(
              'در حال ساخت PDF',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لطفاً کمی صبر کنید...',
              style: TextStyle(
                fontSize: 13,
                color: _charcoal.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
