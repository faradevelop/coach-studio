// lib/features/workout_programs/presentation/pages/program_exercise_wizard_page.dart

import 'dart:ui';

import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_dropdown.dart';
import 'package:coach_studio/core/widgets/app_number_picker.dart';
import 'package:coach_studio/core/widgets/app_stepper.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/core/widgets/custom_search_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
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
/// route/one Navigator entry for all of them.
class ProgramExerciseWizardPage extends StatelessWidget {
  final String programId;

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

  WorkoutProgram? _resolveProgram(WorkoutProgramState state) {
    if (state is WorkoutProgramLoaded) {
      for (final program in state.programs) {
        if (program.id == widget.programId) {
          return program;
        }
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
          return const Scaffold(body: Center(child: _WizardLoadingIndicator()));
        }

        return BlocConsumer<
          ProgramExerciseWizardCubit,
          ProgramExerciseWizardState
        >(
          listenWhen: (p, c) =>
              p.errorMessage != c.errorMessage && c.errorMessage != null,
          listener: (context, state) {
            sl<AppNotification>().error(state.errorMessage!);
          },
          builder: (context, wizardState) {
            return PopScope(
              canPop: wizardState.step == WizardStep.day,
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) {
                  return;
                }

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
                              onQueryChanged: (v) {
                                setState(() {
                                  _query = v;
                                });
                              },
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
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.hexagonDots(
      color: AppColors.orange,
      size: 40,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AppBar
// ─────────────────────────────────────────────────────────────

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
      child: MaxWidthBox(
        maxWidth: AppContentWidth.form,
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
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
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

// ─────────────────────────────────────────────────────────────
// Step 1
// ─────────────────────────────────────────────────────────────

class _DayStep extends StatelessWidget {
  final WorkoutProgram program;

  const _DayStep({required this.program});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProgramExerciseWizardCubit>();

    final state = context.watch<ProgramExerciseWizardCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: MaxWidthBox(
        maxWidth: AppContentWidth.form,
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
                  if (value != null) {
                    cubit.setDay(value);
                  }
                },
              ),
              const SizedBox(height: 20),
              AppDropdown<TrainingSystem>(
                label: 'سیستم تمرینی',
                value: state.trainingSystem,
                items: TrainingSystem.values,
                itemLabel: (item) => item.label,
                onChanged: (value) {
                  if (value != null) {
                    cubit.setTrainingSystem(value);
                  }
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 2
// ─────────────────────────────────────────────────────────────

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
    if (query.trim().isEmpty) {
      return exercises;
    }

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

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: MaxWidthBox(
        maxWidth: AppContentWidth.form,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
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
                      '${wizardState.selectedExercises.length.persianNumber}/${wizardState.maxSelection.persianNumber}',
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
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 20),
                          itemCount: filtered.length,
                          itemBuilder: (_, index) {
                            final exercise = filtered[index];

                            final isSelected = wizardState.selectedExercises
                                .any((e) => e.id == exercise.id);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: GestureDetector(
                                onTap: () {
                                  final isSelected = wizardState
                                      .selectedExercises
                                      .any((e) => e.id == exercise.id);

                                  if (!isSelected &&
                                      wizardState.selectedExercises.length >=
                                          wizardState.maxSelection) {
                                    sl<AppNotification>().warning(
                                      'حداکثر ${wizardState.maxSelection} تمرین می‌توانید انتخاب کنید.',
                                    );
                                    return;
                                  }

                                  wizardCubit.toggleExerciseSelection(exercise);
                                },
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
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
              child: AppButton(
                text: 'تایید و مرحله بعد',
                onPressed: wizardCubit.canProceedToConfigure
                    ? wizardCubit.goToConfigure
                    : null,
              ),
            ),
          ],
        ),
      ),
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
                ? AppColors.teal.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.40),
            borderRadius: BorderRadius.circular(AppRadius.lg - 4),
            border: Border.all(
              color: isSelected
                  ? AppColors.teal.withValues(alpha: 0.6)
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
                      ? AppColors.teal
                      : Colors.white.withValues(alpha: 0.5),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.teal
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

// ─────────────────────────────────────────────────────────────
// Step 3
// ─────────────────────────────────────────────────────────────

class _ConfigureStep extends StatefulWidget {
  const _ConfigureStep();

  @override
  State<_ConfigureStep> createState() => _ConfigureStepState();
}

class _ConfigureStepState extends State<_ConfigureStep> {
  late int _setsCount;
  late int _restSeconds;

  /// exerciseId -> reps for each set.
  final Map<String, List<int>> _repsValues = {};

  final Map<String, TextEditingController> _tempoControllers = {};
  final Map<String, TextEditingController> _descriptionControllers = {};

  @override
  void initState() {
    super.initState();

    final state = context.read<ProgramExerciseWizardCubit>().state;

    _setsCount = _parseSets(state.sets);
    _restSeconds = _parseRest(state.rest);

    for (final exercise in state.selectedExercises) {
      final config =
          state.itemConfigs[exercise.id] ?? const ExerciseItemConfig();

      _repsValues[exercise.id] = List.generate(_setsCount, (index) {
        if (config.reps.length == 1) {
          return _parseRep(config.reps.first);
        }
        if (index < config.reps.length) {
          return _parseRep(config.reps[index]);
        }
        return 1;
      });

      _tempoControllers[exercise.id] = TextEditingController(
        text: config.tempo,
      );
      _descriptionControllers[exercise.id] = TextEditingController(
        text: config.description,
      );
    }
  }

  int _parseSets(String value) {
    final count = int.tryParse(value.trim());
    if (count == null) return 1;
    return count.clamp(1, 100);
  }

  int _parseRest(String value) {
    final seconds = int.tryParse(value.trim());
    if (seconds == null) return 0;
    return seconds.clamp(0, 600);
  }

  int _parseRep(String value) {
    final reps = int.tryParse(value.trim());
    if (reps == null) return 1;
    return reps.clamp(1, 100);
  }

  void _onSetsChanged(int newCount) {
    if (newCount == _setsCount) return;
    setState(() {
      _setsCount = newCount;
      _syncRepsValues();
    });
  }

  void _onRestChanged(int seconds) {
    setState(() => _restSeconds = seconds);
  }

  void _onRepChanged(String exerciseId, int setIndex, int reps) {
    setState(() => _repsValues[exerciseId]![setIndex] = reps);
  }

  void _syncRepsValues() {
    final state = context.read<ProgramExerciseWizardCubit>().state;
    for (final exercise in state.selectedExercises) {
      final reps = _repsValues[exercise.id]!;
      if (reps.length < _setsCount) {
        reps.addAll(List.filled(_setsCount - reps.length, 1));
      } else if (reps.length > _setsCount) {
        reps.removeRange(_setsCount, reps.length);
      }
    }
  }

  @override
  void dispose() {
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
      ..setSets(_setsCount.toString())
      ..setRest(_restSeconds.toString());

    for (final exercise in cubit.state.selectedExercises) {
      cubit.updateItemConfig(
        exercise.id,
        reps: _repsValues[exercise.id]!
            .map((value) => value.toString())
            .toList(),
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
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = context.watch<ProgramExerciseWizardCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: MaxWidthBox(
        maxWidth: AppContentWidth.form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Global settings ──────────────────────────────
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta row
                  Row(
                    children: [
                      _MetaChip(
                        label: wizardState.trainingSystem.label,
                        color: AppColors.teal,
                        softColor: AppColors.teal.withValues(alpha: 0.12),
                      ),
                      const SizedBox(width: 6),
                      _MetaChip(
                        label: 'روز ${wizardState.day}',
                        color: AppColors.charcoal.withValues(alpha: 0.65),
                        softColor: AppColors.glass,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Section title
                  _SectionLabel(text: 'تنظیمات کلی'),

                  const SizedBox(height: 16),

                  AppStepper(
                    label: 'تعداد ست',
                    value: _setsCount,
                    onChanged: _onSetsChanged,
                  ),

                  const SizedBox(height: 14),

                  AppNumberPicker(
                    label: 'استراحت (ثانیه)',
                    value: _restSeconds,
                    min: 0,
                    max: 600,
                    onChanged: _onRestChanged,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Per-exercise cards ───────────────────────────
            ...wizardState.selectedExercises.map((exercise) {
              final reps = _repsValues[exercise.id]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Exercise header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${exercise.targetMuscle.label}  •  ${exercise.equipment.label}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.muted,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_setsCount.persianNumber} ست',
                              style: const TextStyle(
                                color: AppColors.teal,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Reps section
                      _SectionLabel(text: 'تکرارها'),

                      const SizedBox(height: 16),

                      ...List.generate(_setsCount, (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _setsCount - 1 ? 0 : 10,
                          ),
                          child: AppNumberPicker(
                            label: 'ست ${index + 1}',
                            value: reps[index],
                            min: 1,
                            max: 100,
                            onChanged: (value) {
                              _onRepChanged(exercise.id, index, value);
                            },
                          ),
                        );
                      }),

                      const SizedBox(height: 22),

                      // Extra fields
                      _SectionLabel(text: 'جزئیات بیشتر'),

                      const SizedBox(height: 16),

                      AppTextField(
                        controller: _tempoControllers[exercise.id]!,
                        label: 'تمپو',
                      ),

                      const SizedBox(height: 12),

                      AppTextField(
                        controller: _descriptionControllers[exercise.id]!,
                        label: 'توضیح',
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            AppButton(
              text: 'تأیید و ذخیره',
              isLoading: wizardState.isSubmitting,
              onPressed: wizardState.isSubmitting
                  ? null
                  : () => _submit(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small UI helpers for Step 3 ──────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.charcoal.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
            fontSize: 13,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color softColor;

  const _MetaChip({
    required this.label,
    required this.color,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: softColor,
        borderRadius: BorderRadius.circular(20),
        //border: Border.all(color: color.withValues(alpha: 0.18), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Glass Card
// ─────────────────────────────────────────────────────────────

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
