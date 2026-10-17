// lib/features/workout_programs/presentation/pages/exercise_configuration_page.dart

import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_number_picker.dart';
import 'package:coach_studio/core/widgets/app_stepper.dart';
import 'package:coach_studio/core/widgets/app_surface.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/core/widgets/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
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
/// [ProgramExerciseCubit]'s already-loaded state via [programExerciseId].
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
        if (details.programExercise.id == programExerciseId) {
          return details;
        }
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
            backgroundColor: AppColors.background,
            body: Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.primary,
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
  /// exerciseId -> reps for each set.
  ///
  /// Example:
  ///
  /// exercise-1 -> [12, 10, 10, 8]
  ///
  /// means this exercise has 4 sets with different reps.
  final Map<String, List<int>> _repsValues = {};

  final Map<String, TextEditingController> _tempoControllers = {};
  final Map<String, TextEditingController> _descriptionControllers = {};

  late int _setsCount;
  late int _restSeconds;

  bool _isSubmitting = false;

  ProgramExercise get _existing => widget.details.programExercise;

  @override
  void initState() {
    super.initState();

    _setsCount = _parseSets(_existing.sets);
    _restSeconds = _parseRest(_existing.rest);

    for (final itemDetails in widget.details.items) {
      final exerciseId = itemDetails.exercise.id;
      final reps = itemDetails.item.reps;

      _repsValues[exerciseId] = List.generate(_setsCount, (index) {
        if (reps.length == 1) {
          return _parseRep(reps.first);
        }

        if (index < reps.length) {
          return _parseRep(reps[index]);
        }

        return 1;
      });

      _tempoControllers[exerciseId] = TextEditingController(
        text: itemDetails.item.tempo,
      );

      _descriptionControllers[exerciseId] = TextEditingController(
        text: itemDetails.item.description ?? '',
      );
    }
  }

  int _parseSets(String value) {
    final count = int.tryParse(value.trim());

    if (count == null) {
      return 1;
    }

    return count.clamp(1, 100);
  }

  int _parseRest(String value) {
    final seconds = int.tryParse(value.trim());

    if (seconds == null) {
      return 0;
    }

    return seconds.clamp(0, 600);
  }

  int _parseRep(String value) {
    final reps = int.tryParse(value.trim());

    if (reps == null) {
      return 1;
    }

    return reps.clamp(1, 100);
  }

  void _onSetsChanged(int newCount) {
    if (newCount == _setsCount) {
      return;
    }

    setState(() {
      _setsCount = newCount;
      _syncRepsValues();
    });
  }

  void _onRestChanged(int seconds) {
    setState(() {
      _restSeconds = seconds;
    });
  }

  void _onRepChanged(String exerciseId, int setIndex, int reps) {
    setState(() {
      _repsValues[exerciseId]![setIndex] = reps;
    });
  }

  void _syncRepsValues() {
    for (final itemDetails in widget.details.items) {
      final exerciseId = itemDetails.exercise.id;
      final reps = _repsValues[exerciseId]!;

      if (reps.length < _setsCount) {
        reps.addAll(List.filled(_setsCount - reps.length, 1));
      } else if (reps.length > _setsCount) {
        reps.removeRange(_setsCount, reps.length);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _tempoControllers.values) {
      controller.dispose();
    }

    for (final controller in _descriptionControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final items = widget.details.items.asMap().entries.map((entry) {
        final index = entry.key;
        final itemDetails = entry.value;

        final exerciseId = itemDetails.exercise.id;
        final existingItem = itemDetails.item;

        return ProgramExerciseItem(
          id: existingItem.id,
          programExerciseId: _existing.id,
          exerciseId: exerciseId,
          order: index + 1,
          reps: _repsValues[exerciseId]!
              .map((value) => value.toString())
              .toList(),
          tempo: _tempoControllers[exerciseId]!.text,
          description: _descriptionControllers[exerciseId]!.text.isEmpty
              ? null
              : _descriptionControllers[exerciseId]!.text,
        );
      }).toList();

      final updated = _existing.copyWith(
        sets: _setsCount.toString(),
        rest: _restSeconds.toString(),
        items: items,
      );

      final success = await context
          .read<ProgramExerciseCubit>()
          .updateProgramExercise(updated);

      if (!success) {
        if (mounted) {
          sl<AppNotification>().error('ویرایش تمرین ناموفق بود.');
        }

        return;
      }

      if (mounted) {
        sl<AppNotification>().success('تمرین با موفقیت ویرایش شد.');

        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
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
              maxWidth: AppContentWidth.form,
              child: const InnerPagesAppBar(
                rightButton: SizedBox(width: 40),
                title: 'ویرایش تمرین',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: MaxWidthBox(
                  maxWidth: AppContentWidth.form,
                  child: Column(
                    children: [
                      _Card(
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
                                    color: AppColors.secondarySoft,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _existing.trainingSystem.label,
                                    style: const TextStyle(
                                      color: AppColors.secondaryDark,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'روز ${_existing.day.persianNumber}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),

                            AppStepper(
                              label: 'ست',
                              value: _setsCount,
                              onChanged: _onSetsChanged,
                            ),

                            const SizedBox(height: 16),

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

                      const SizedBox(height: AppSpacing.lg - 4),

                      ...widget.details.items.map((itemDetails) {
                        final exercise = itemDetails.exercise;
                        final reps = _repsValues[exercise.id]!;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _Card(
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

                                Text('تکرار', style: AppTextStyles.bodySmall),

                                const SizedBox(height: 8),

                                ...List.generate(_setsCount, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
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

                                const SizedBox(height: 4),

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
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.all(18),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}
