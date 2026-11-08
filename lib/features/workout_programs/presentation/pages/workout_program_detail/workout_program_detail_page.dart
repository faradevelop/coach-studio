import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
import 'package:coach_studio/core/widgets/feedback/app_loading_indicator.dart';
import 'package:coach_studio/core/widgets/navigation/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/workout_programs/data/services/workout_program_pdf_generator.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/athlete_info.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_details.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_detail/widgets/exercises_section_header.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_detail/widgets/pdf_action_button.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_detail/widgets/pdf_loading_dialog.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_detail/widgets/program_exercises_view.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_detail/widgets/program_info_card.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/athlete_info_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

/// Resolves the program (list state first, then [seedProgram]) and loads
/// its exercises. Rendering lives in [_WorkoutProgramDetailView].
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

  WorkoutProgram? _resolveProgram(WorkoutProgramState state) {
    if (state case WorkoutProgramLoaded(:final programs)) {
      for (final program in programs) {
        if (program.id == widget.programId) return program;
      }
    }
    return widget.seedProgram;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
      builder: (context, state) {
        final program = _resolveProgram(state);

        if (program != null) return _WorkoutProgramDetailView(program: program);

        // Distinguish "list still loading" from "genuinely not found"
        // (e.g. deleted elsewhere, or a stale bookmark).
        if (state is WorkoutProgramLoaded) return const _ProgramNotFoundState();

        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: AppLoadingIndicator()),
        );
      },
    );
  }
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

  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

  void _addExercise() {
    context.pushNamed(
      AppRouteNames.createProgramExercise,
      pathParameters: {'programId': widget.program.id},
      queryParameters: {'day': _selectedDay.toString()},
      extra: widget.program,
    );
  }

  Future<void> _generatePdf() async {
    final state = context.read<ProgramExerciseCubit>().state;

    if (state is! ProgramExerciseLoaded || state.exercises.isEmpty) {
      sl<AppNotification>().warning('ابتدا تمرین ایجاد کنید!');
      return;
    }

    final athlete = await showDialog<AthleteInfo>(
      context: context,
      builder: (_) => const AthleteInfoFormDialog(),
    );

    if (athlete == null || !mounted) return;

    setState(() => _isGeneratingPdf = true);

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => const PdfLoadingDialog(),
    );

    var succeeded = false;
    try {
      await _buildAndSharePdf(state.exercises, athlete);
      succeeded = true;
    } catch (e, st) {
      sl<AppLogger>().error('PDF generation failed', error: e, stackTrace: st);
    }

    // Closes ONLY the loading dialog (never the page behind it).
    rootNavigator.pop();

    if (mounted) {
      setState(() => _isGeneratingPdf = false);
      if (succeeded) {
        sl<AppNotification>().success('PDF برنامه ایجاد شد!');
      } else {
        sl<AppNotification>().error('ساخت PDF با خطا مواجه شد');
      }
    }
  }

  Future<void> _buildAndSharePdf(
    List<ProgramExerciseDetails> exercises,
    AthleteInfo athlete,
  ) async {
    final details = WorkoutProgramDetails(
      program: widget.program,
      exercises: exercises,
    );

    final bytes = await WorkoutProgramPdfGenerator().generate(
      details: details,
      athlete: athlete,
    );

    await Printing.sharePdf(
      bytes: bytes,
      filename: '${widget.program.title}.pdf',
    );
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
                rightButton: PdfActionButton(
                  enabled: !_isGeneratingPdf,
                  onTap: _generatePdf,
                ),
                title: 'جزئیات برنامه',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 32),
                child: MaxWidthBox(
                  maxWidth: AppContentWidth.detail,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: ProgramInfoCard(program: widget.program),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: ExercisesSectionHeader(
                          onAddPressed: _addExercise,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ProgramExercisesView(
                        program: widget.program,
                        selectedDay: _selectedDay,
                        scrollController: _scrollController,
                        onDayChanged: (day) =>
                            setState(() => _selectedDay = day),
                      ),
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
}
