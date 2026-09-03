// lib/features/workout_programs/presentation/pages/exercise_configuration_page.dart
import 'dart:ui';

import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_item.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Edits an EXISTING ProgramExercise (create now lives entirely in
/// ProgramExerciseWizardPage). All required data is resolved from
/// [ProgramExerciseCubit]'s already-loaded state via [programExerciseId]
/// — `ProgramExerciseDetails` already embeds the joined Exercise
/// entities, so no separate lookup is needed. `extra` is optional.
class ExerciseConfigurationPage extends StatelessWidget {
  final String programExerciseId;
  final ProgramExerciseDetails? seedDetails;

  const ExerciseConfigurationPage({
    super.key,
    required this.programExerciseId,
    this.seedDetails,
  });

  ProgramExerciseDetails? _resolve(ProgramExerciseState state) {
    if (state is ProgramExerciseLoaded) {
      for (final details in state.exercises) {
        if (details.programExercise.id == programExerciseId) return details;
      }
    }
    return seedDetails;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProgramExerciseCubit, ProgramExerciseState>(
      builder: (context, state) {
        final details = _resolve(state);

        if (details == null) {
          return Scaffold(
            backgroundColor: AppColors.cream,
            body: Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.orange,
                size: 40,
              ),
            ),
          );
        }

        return _EditProgramExerciseView(details: details);
      },
    );
  }
}

class _EditProgramExerciseView extends StatefulWidget {
  final ProgramExerciseDetails details;
  const _EditProgramExerciseView({required this.details});

  @override
  State<_EditProgramExerciseView> createState() =>
      _EditProgramExerciseViewState();
}

class _EditProgramExerciseViewState extends State<_EditProgramExerciseView> {
  final _setsController = TextEditingController();
  final _restController = TextEditingController();
  final Map<String, TextEditingController> _repsControllers = {};
  final Map<String, TextEditingController> _tempoControllers = {};
  final Map<String, TextEditingController> _descriptionControllers = {};

  ProgramExercise get _existing => widget.details.programExercise;

  @override
  void initState() {
    super.initState();
    _setsController.text = _existing.sets;
    _restController.text = _existing.rest;

    for (final itemDetails in widget.details.items) {
      final id = itemDetails.exercise.id;
      _repsControllers[id] = TextEditingController(text: itemDetails.item.reps);
      _tempoControllers[id] = TextEditingController(
        text: itemDetails.item.tempo,
      );
      _descriptionControllers[id] = TextEditingController(
        text: itemDetails.item.description ?? '',
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

  bool _isSubmitting = false;

  Future<void> _save() async {
    setState(() => _isSubmitting = true);
    try {
      final items = widget.details.items.asMap().entries.map((entry) {
        final index = entry.key;
        final exerciseId = entry.value.exercise.id;
        final existingItem = entry.value.item;

        return ProgramExerciseItem(
          id: existingItem.id,
          programExerciseId: _existing.id,
          exerciseId: exerciseId,
          order: index + 1,
          reps: _repsControllers[exerciseId]!.text,
          tempo: _tempoControllers[exerciseId]!.text,
          description: _descriptionControllers[exerciseId]!.text.isEmpty
              ? null
              : _descriptionControllers[exerciseId]!.text,
        );
      }).toList();

      final updated = _existing.copyWith(
        sets: _setsController.text,
        rest: _restController.text,
        items: items,
      );

      final success = await context
          .read<ProgramExerciseCubit>()
          .updateProgramExercise(updated);
      if (!success) {
        if (mounted) sl<AppNotification>().error('ویرایش تمرین ناموفق بود.');
        return;
      }

      if (mounted) {
        sl<AppNotification>().success('تمرین با موفقیت ویرایش شد.');
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    const Spacer(),
                    Column(
                      children: [
                        Text('ویرایش تمرین', style: AppTextStyles.titleMedium),
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
                    GlassyBackButton(onTap: () => context.pop()),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
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
                                    color: AppColors.teal.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _existing.trainingSystem.label,
                                    style: const TextStyle(
                                      color: AppColors.teal,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'روز ${_existing.day}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            AppTextField(
                              controller: _setsController,
                              label: 'ست',
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _restController,
                              label: 'استراحت',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg - 4),
                      ...widget.details.items.map((itemDetails) {
                        final exercise = itemDetails.exercise;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    fontSize: 16,
                                  ),
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
                                  controller:
                                      _descriptionControllers[exercise.id]!,
                                  label: 'توضیح',
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'ویرایش',
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _save,
                      ),
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
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
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
