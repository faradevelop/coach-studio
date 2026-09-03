// lib/features/workout_programs/presentation/pages/program_exercise_wizard_page.dart
import 'dart:ui';

import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_dropdown.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/core/widgets/custom_search_bar.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// The SINGLE GoRoute destination for the whole "add program exercise"
/// flow. It has 3 internal steps, but GoRouter only ever sees one
/// route/one Navigator entry for all of them — step transitions are
/// pure Cubit state changes, never navigation.
class ProgramExerciseWizardPage extends StatelessWidget {
  final String programId;

  /// Optional fast path only. If absent (browser refresh, deep link,
  /// Back/Forward reconstruction) the page resolves the program from
  /// [WorkoutProgramCubit]'s already-loaded state instead.
  final WorkoutProgram? seedProgram;

  const ProgramExerciseWizardPage({
    super.key,
    required this.programId,
    this.seedProgram,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgramExerciseWizardCubit(
        programId: programId,
        programExerciseCubit: context.read<ProgramExerciseCubit>(),
        logger: sl(),
      ),
      child: _WizardView(programId: programId, seedProgram: seedProgram),
    );
  }
}

class _WizardView extends StatefulWidget {
  final String programId;
  final WorkoutProgram? seedProgram;

  const _WizardView({required this.programId, this.seedProgram});

  @override
  State<_WizardView> createState() => _WizardViewState();
}

class _WizardViewState extends State<_WizardView> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Required state, resolved purely from `programId` + the already-
  /// loaded WorkoutProgramCubit. `seedProgram` only avoids a flash on
  /// the very first frame when it happens to be available.
  WorkoutProgram? _resolveProgram(WorkoutProgramState state) {
    if (state is WorkoutProgramLoaded) {
      for (final program in state.programs) {
        if (program.id == widget.programId) return program;
      }
    }
    return widget.seedProgram;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
      builder: (context, programState) {
        final program = _resolveProgram(programState);

        if (program == null) {
          // Not loaded yet (e.g. a hard refresh landed directly on this
          // URL) — show a loading state, not a crash. WorkoutProgramCubit
          // is a global singleton already loading from main.dart, so
          // this resolves itself as soon as its stream emits.
          return const Scaffold(body: Center(child: _WizardLoadingIndicator()));
        }

        return BlocConsumer<
          ProgramExerciseWizardCubit,
          ProgramExerciseWizardState
        >(
          listenWhen: (p, c) =>
              p.errorMessage != c.errorMessage && c.errorMessage != null,
          listener: (context, state) =>
              sl<AppNotification>().error(state.errorMessage!),
          builder: (context, wizardState) {
            return PopScope(
              // Only a real pop (back gesture, browser Back, hardware
              // Back, AppBar arrow via maybePop) is allowed to leave the
              // wizard when we're on the FIRST step. Otherwise it's
              // intercepted and turned into a step-back. This single
              // PopScope is what makes System Back, the back gesture,
              // AND the browser Back button all behave identically —
              // they all funnel through the same Navigator pop attempt
              // that PopScope governs.
              canPop: wizardState.step == WizardStep.day,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) return;
                context.read<ProgramExerciseWizardCubit>().goToPreviousStep();
              },
              child: Scaffold(
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
                        _WizardAppBar(step: wizardState.step),
                        Expanded(
                          child: switch (wizardState.step) {
                            WizardStep.day => _DayStep(program: program),
                            WizardStep.selectExercises => _SelectExercisesStep(
                              searchController: _searchController,
                              query: _query,
                              onQueryChanged: (v) => setState(() => _query = v),
                            ),
                            WizardStep.configure => const _ConfigureStep(),
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _WizardLoadingIndicator extends StatelessWidget {
  const _WizardLoadingIndicator();
  @override
  Widget build(BuildContext context) =>
      LoadingAnimationWidget.hexagonDots(color: AppColors.orange, size: 40);
}

// ── AppBar with step dots ────────────────────────────────────

class _WizardAppBar extends StatelessWidget {
  final WizardStep step;
  const _WizardAppBar({required this.step});

  String get _title => switch (step) {
    WizardStep.day => 'تمرین جدید',
    WizardStep.selectExercises => 'انتخاب تمرین',
    WizardStep.configure => 'تنظیم تمرین',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          _StepDots(currentStep: step),
          const Spacer(),
          Column(
            children: [
              Text(_title, style: AppTextStyles.titleMedium),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: 90,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            // Routed through maybePop() — the SAME mechanism System
            // Back / the gesture / browser Back use — so the in-app
            // arrow and external Back are always consistent.
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: const Directionality(
                textDirection: TextDirection.ltr,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.charcoal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  final WizardStep currentStep;
  const _StepDots({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final index = WizardStep.values.indexOf(currentStep);
    return Row(
      children: List.generate(WizardStep.values.length, (i) {
        final active = i <= index;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? AppColors.orange
                  : AppColors.charcoal.withValues(alpha: 0.15),
            ),
          ),
        );
      }),
    );
  }
}

// ── Step 1 ────────────────────────────────────────────────────

class _DayStep extends StatelessWidget {
  final WorkoutProgram program;
  const _DayStep({required this.program});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProgramExerciseWizardCubit>();
    final state = context.watch<ProgramExerciseWizardCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: _GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppDropdown<int>(
              label: 'روز تمرین',
              value: state.day,
              items: List.generate(program.daysPerWeek, (i) => i + 1),
              itemLabel: (day) => 'روز $day',
              onChanged: (value) {
                if (value != null) cubit.setDay(value);
              },
            ),
            const SizedBox(height: 20),
            AppDropdown<TrainingSystem>(
              label: 'سیستم تمرینی',
              value: state.trainingSystem,
              items: TrainingSystem.values,
              itemLabel: (item) => item.label,
              onChanged: (value) {
                if (value != null) cubit.setTrainingSystem(value);
              },
            ),
            const SizedBox(height: 36),
            AppButton(
              text: 'تایید و مرحله بعد',
              onPressed: cubit.goToSelectExercises,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Step 2 ────────────────────────────────────────────────────

class _SelectExercisesStep extends StatelessWidget {
  final TextEditingController searchController;
  final String query;
  final ValueChanged<String> onQueryChanged;

  const _SelectExercisesStep({
    required this.searchController,
    required this.query,
    required this.onQueryChanged,
  });

  List<Exercise> _filter(List<Exercise> exercises) {
    if (query.trim().isEmpty) return exercises;
    final q = query.trim().toLowerCase();
    return exercises
        .where(
          (e) =>
              e.name.contains(q) ||
              e.targetMuscle.label.contains(q) ||
              e.equipment.label.contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final wizardCubit = context.read<ProgramExerciseWizardCubit>();
    final wizardState = context.watch<ProgramExerciseWizardCubit>().state;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: CustomSearchBar(
                  hint: 'جستجو ...',
                  controller: searchController,
                  onChanged: onQueryChanged,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${wizardState.selectedExercises.length}/${wizardState.maxSelection}',
                  style: const TextStyle(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: BlocBuilder<ExerciseCubit, ExerciseState>(
            builder: (context, state) {
              return switch (state) {
                ExerciseLoading() => Center(
                  child: LoadingAnimationWidget.hexagonDots(
                    color: AppColors.orange,
                    size: 40,
                  ),
                ),
                ExerciseError() => const Center(
                  child: Text('خطا در بارگذاری تمرین‌ها'),
                ),
                ExerciseLoaded(:final exercises) => Builder(
                  builder: (_) {
                    final filtered = _filter(exercises);
                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          'تمرینی پیدا نشد!',
                          style: AppTextStyles.subtitle,
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                      itemCount: filtered.length,
                      itemBuilder: (_, index) {
                        final exercise = filtered[index];
                        final isSelected = wizardState.selectedExercises.any(
                          (e) => e.id == exercise.id,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: GestureDetector(
                            onTap: () =>
                                wizardCubit.toggleExerciseSelection(exercise),
                            child: _ExerciseSelectTile(
                              exercise: exercise,
                              isSelected: isSelected,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                _ => const SizedBox(),
              };
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: AppButton(
            text: 'تایید و مرحله بعد',
            onPressed: wizardCubit.canProceedToConfigure
                ? wizardCubit.goToConfigure
                : null,
          ),
        ),
      ],
    );
  }
}

class _ExerciseSelectTile extends StatelessWidget {
  final Exercise exercise;
  final bool isSelected;
  const _ExerciseSelectTile({required this.exercise, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg - 4),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.orange.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(AppRadius.lg - 4),
            border: Border.all(
              color: isSelected
                  ? AppColors.orange.withValues(alpha: 0.6)
                  : AppColors.glassBorder,
              width: isSelected ? 1.5 : 1.1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.orange
                      : Colors.white.withValues(alpha: 0.5),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.orange
                        : AppColors.charcoal.withValues(alpha: 0.3),
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${exercise.targetMuscle.label}  •  ${exercise.equipment.label}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.charcoal.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Step 3 ────────────────────────────────────────────────────

class _ConfigureStep extends StatefulWidget {
  const _ConfigureStep();
  @override
  State<_ConfigureStep> createState() => _ConfigureStepState();
}

class _ConfigureStepState extends State<_ConfigureStep> {
  late final TextEditingController _setsController;
  late final TextEditingController _restController;
  final Map<String, TextEditingController> _repsControllers = {};
  final Map<String, TextEditingController> _tempoControllers = {};
  final Map<String, TextEditingController> _descriptionControllers = {};

  @override
  void initState() {
    super.initState();
    final state = context.read<ProgramExerciseWizardCubit>().state;
    _setsController = TextEditingController(text: state.sets);
    _restController = TextEditingController(text: state.rest);

    for (final exercise in state.selectedExercises) {
      final config =
          state.itemConfigs[exercise.id] ?? const ExerciseItemConfig();
      _repsControllers[exercise.id] = TextEditingController(text: config.reps);
      _tempoControllers[exercise.id] = TextEditingController(
        text: config.tempo,
      );
      _descriptionControllers[exercise.id] = TextEditingController(
        text: config.description,
      );
    }
  }

  @override
  void dispose() {
    _setsController.dispose();
    _restController.dispose();
    for (final c in _repsControllers.values) {
      c.dispose();
    }
    for (final c in _tempoControllers.values) {
      c.dispose();
    }
    for (final c in _descriptionControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final cubit = context.read<ProgramExerciseWizardCubit>();

    cubit
      ..setSets(_setsController.text)
      ..setRest(_restController.text);

    for (final exercise in cubit.state.selectedExercises) {
      cubit.updateItemConfig(
        exercise.id,
        reps: _repsControllers[exercise.id]!.text,
        tempo: _tempoControllers[exercise.id]!.text,
        description: _descriptionControllers[exercise.id]!.text,
      );
    }

    final success = await cubit.submit();
    if (!context.mounted) return;

    if (!success) {
      sl<AppNotification>().error('ایجاد تمرین ناموفق بود.');
      return;
    }

    sl<AppNotification>().success('تمرین با موفقیت ایجاد شد.');
    // NOTE: context.pop() -> Navigator.pop(), which is UNCONDITIONAL and
    // bypasses PopScope entirely (PopScope only governs maybePop-style
    // attempts: system back / gesture / browser back / the in-app arrow
    // above). So this always leaves the wizard cleanly regardless of
    // which internal step we were last on, landing on whatever's
    // directly beneath on the Navigator stack — the Detail page —
    // while leaving the rest of the back-history (e.g. the Programs
    // list) fully intact.
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = context.watch<ProgramExerciseWizardCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        children: [
          _GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        wizardState.trainingSystem.label,
                        style: const TextStyle(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'روز ${wizardState.day}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AppTextField(controller: _setsController, label: 'ست'),
                const SizedBox(height: 16),
                AppTextField(controller: _restController, label: 'استراحت'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ...wizardState.selectedExercises.map((exercise) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _repsControllers[exercise.id]!,
                      label: 'تکرار',
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _tempoControllers[exercise.id]!,
                      label: 'تمپو',
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _descriptionControllers[exercise.id]!,
                      label: 'توضیح',
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          AppButton(
            text: 'تایید',
            isLoading: wizardState.isSubmitting,
            onPressed: wizardState.isSubmitting ? null : () => _submit(context),
          ),
        ],
      ),
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
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.38),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.glassBorder, width: 1.2),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
