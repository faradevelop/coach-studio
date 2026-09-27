import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_number_picker.dart';
import 'package:coach_studio/core/widgets/app_stepper.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/program_exercise_wizard/widgets/wizard_common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WizardConfigureStep extends StatefulWidget {
  const WizardConfigureStep({super.key});

  @override
  State<WizardConfigureStep> createState() => _WizardConfigureStepState();
}

class _WizardConfigureStepState extends State<WizardConfigureStep> {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  late int _setsCount;
  late int _restSeconds;

  final Map<String, List<int>> _repsValues = {};

  final Map<String, TextEditingController> _tempoControllers = {};
  final Map<String, TextEditingController> _descriptionControllers = {};

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    final state = context.read<ProgramExerciseWizardCubit>().state;

    _setsCount = _parseSets(state.sets);
    _restSeconds = _parseRest(state.rest);

    _initializeExerciseValues(state);
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

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  void _initializeExerciseValues(ProgramExerciseWizardState state) {
    for (final exercise in state.selectedExercises) {
      final config =
          state.itemConfigs[exercise.id] ?? const ExerciseItemConfig();

      _repsValues[exercise.id] = _buildInitialReps(config);

      _tempoControllers[exercise.id] = TextEditingController(
        text: config.tempo,
      );

      _descriptionControllers[exercise.id] = TextEditingController(
        text: config.description,
      );
    }
  }

  List<int> _buildInitialReps(ExerciseItemConfig config) {
    return List.generate(_setsCount, (index) {
      if (config.reps.length == 1) {
        return _parseRep(config.reps.first);
      }

      if (index < config.reps.length) {
        return _parseRep(config.reps[index]);
      }

      return 1;
    });
  }

  // ---------------------------------------------------------------------------
  // Parsing
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Change Handlers
  // ---------------------------------------------------------------------------

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
    setState(() => _restSeconds = seconds);
  }

  void _onRepChanged(String exerciseId, int setIndex, int reps) {
    setState(() => _repsValues[exerciseId]![setIndex] = reps);
  }

  // ---------------------------------------------------------------------------
  // Synchronization
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  void _saveCurrentConfiguration(ProgramExerciseWizardCubit cubit) {
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
  }

  Future<void> _submit(BuildContext context) async {
    final cubit = context.read<ProgramExerciseWizardCubit>();

    _saveCurrentConfiguration(cubit);

    final success = await cubit.submit();

    if (!context.mounted) {
      return;
    }

    if (!success) {
      sl<AppNotification>().error('ایجاد تمرین ناموفق بود.');
      return;
    }

    sl<AppNotification>().success('تمرین با موفقیت ایجاد شد.');

    context.pop();
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProgramExerciseWizardCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: MaxWidthBox(
        maxWidth: AppContentWidth.form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGlobalSettings(state),
            const SizedBox(height: 18),
            ...state.selectedExercises.map(_buildExerciseCard),
            const SizedBox(height: 12),
            _buildSubmitButton(state),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalSettings(ProgramExerciseWizardState state) {
    return WizardGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetaRow(state),
          const SizedBox(height: 24),
          const WizardSectionLabel(text: 'تنظیمات کلی'),
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
    );
  }

  Widget _buildMetaRow(ProgramExerciseWizardState state) {
    return Row(
      children: [
        WizardMetaChip(
          label: state.trainingSystem.label,
          color: AppColors.teal,
          softColor: AppColors.teal.withValues(alpha: 0.12),
        ),
        const SizedBox(width: 6),
        WizardMetaChip(
          label: 'روز ${state.day.persianNumber}',
          color: AppColors.charcoal.withValues(alpha: 0.65),
          softColor: AppColors.glass,
        ),
      ],
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    final reps = _repsValues[exercise.id]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: WizardGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExerciseHeader(exercise),
            const SizedBox(height: 18),
            const WizardSectionLabel(text: 'تکرارها'),
            const SizedBox(height: 16),
            _buildRepPickers(exercise, reps),
            const SizedBox(height: 22),
            _buildExtraFields(exercise),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseHeader(Exercise exercise) {
    return Row(
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
              // Text(
              //   '${exercise.targetMuscle.label}  •  ${exercise.equipment.label}',
              //   style: AppTextStyles.bodySmall.copyWith(
              //     color: AppColors.muted,
              //     fontSize: 12.5,
              //   ),
              // ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
    );
  }

  Widget _buildRepPickers(Exercise exercise, List<int> reps) {
    return Column(
      children: List.generate(_setsCount, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == _setsCount - 1 ? 0 : 10),
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
    );
  }

  Widget _buildExtraFields(Exercise exercise) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const WizardSectionLabel(text: 'جزئیات بیشتر'),
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
    );
  }

  Widget _buildSubmitButton(ProgramExerciseWizardState state) {
    return AppButton(
      text: 'تأیید و ذخیره',
      isLoading: state.isSubmitting,
      onPressed: state.isSubmitting ? null : () => _submit(context),
    );
  }
}
