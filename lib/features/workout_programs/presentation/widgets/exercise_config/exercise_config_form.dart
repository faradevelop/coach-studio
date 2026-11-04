// lib/features/workout_programs/presentation/widgets/exercise_config/exercise_config_form.dart
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/core/widgets/inputs/app_number_picker.dart';
import 'package:coach_studio/core/widgets/inputs/app_stepper.dart';
import 'package:coach_studio/core/widgets/inputs/app_text_field.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:flutter/material.dart';

import 'exercise_config_common_widgets.dart';
import 'exercise_config_models.dart';
import 'exercise_config_parser.dart';

/// Shared "configure exercise" form used by BOTH the add-exercise wizard
/// (create) and the edit page.
///
/// It owns only local UI state (sets, rest, reps per set, tempo,
/// description). It knows nothing about Cubits, navigation or
/// notifications: data comes in through [input] and the final values leave
/// through [onSubmit]; persistence is the caller's job.
///
/// [input] is read once in `initState`, so upstream rebuilds never reset
/// what the user is typing. Give the widget a new `Key` to re-initialise it.
class ExerciseConfigForm extends StatefulWidget {
  final ExerciseConfigInput input;
  final String submitLabel;
  final bool isSubmitting;
  final ValueChanged<ExerciseConfigResult> onSubmit;

  const ExerciseConfigForm({
    super.key,
    required this.input,
    required this.submitLabel,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  @override
  State<ExerciseConfigForm> createState() => _ExerciseConfigFormState();
}

class _ExerciseConfigFormState extends State<ExerciseConfigForm> {
  late int _setsCount;
  late int _restSeconds;
  late final List<_ItemDraft> _drafts;

  @override
  void initState() {
    super.initState();

    final input = widget.input;
    _setsCount = ExerciseConfigParser.parseSets(input.sets);
    _restSeconds = ExerciseConfigParser.parseRest(input.rest);

    _drafts = [
      for (final item in input.items)
        _ItemDraft(
          exerciseId: item.exerciseId,
          exerciseName: item.exerciseName,
          reps: ExerciseConfigParser.buildReps(item.reps, _setsCount),
          tempo: item.tempo,
          description: item.description,
        ),
    ];
  }

  @override
  void dispose() {
    for (final draft in _drafts) {
      draft.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Handlers
  // ---------------------------------------------------------------------------

  void _onSetsChanged(int newCount) {
    if (newCount == _setsCount) return;

    setState(() {
      _setsCount = newCount;
      for (final draft in _drafts) {
        ExerciseConfigParser.resizeReps(draft.reps, _setsCount);
      }
    });
  }

  void _onRestChanged(int seconds) {
    setState(() => _restSeconds = seconds);
  }

  void _onRepChanged(_ItemDraft draft, int setIndex, int reps) {
    setState(() => draft.reps[setIndex] = reps);
  }

  void _submit() {
    widget.onSubmit(
      ExerciseConfigResult(
        sets: _setsCount,
        restSeconds: _restSeconds,
        items: [for (final draft in _drafts) draft.toResult()],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      child: MaxWidthBox(
        maxWidth: AppContentWidth.form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGlobalSettings(),
            const SizedBox(height: 18),
            for (final draft in _drafts) _buildExerciseCard(draft),
            const SizedBox(height: 12),
            AppButton(
              text: widget.submitLabel,
              isLoading: widget.isSubmitting,
              onPressed: widget.isSubmitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalSettings() {
    return AppSurface(
      padding: const EdgeInsets.all(22),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetaRow(),
            const SizedBox(height: 24),
            const ExerciseConfigSectionLabel(text: 'تنظیمات کلی'),
            const SizedBox(height: 16),
            AppStepper(
              label: 'تعداد ست',
              value: _setsCount,
              min: ExerciseConfigParser.minSets,
              max: ExerciseConfigParser.maxSets,
              onChanged: _onSetsChanged,
            ),
            const SizedBox(height: 14),
            AppNumberPicker(
              label: 'استراحت (ثانیه)',
              value: _restSeconds,
              min: ExerciseConfigParser.minRest,
              max: ExerciseConfigParser.maxRest,
              onChanged: _onRestChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow() {
    final input = widget.input;

    return Row(
      children: [
        ExerciseConfigMetaChip(
          label: input.trainingSystem.label,
          color: AppColors.secondaryDark,
          softColor: AppColors.secondarySoft,
        ),
        const SizedBox(width: 6),
        ExerciseConfigMetaChip(
          label: 'روز ${input.day.persianNumber}',
          color: AppColors.textSecondary,
          softColor: AppColors.surfaceVariant,
        ),
      ],
    );
  }

  Widget _buildExerciseCard(_ItemDraft draft) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppSurface(
        padding: const EdgeInsets.all(22),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExerciseHeader(draft),
              const SizedBox(height: 18),
              const ExerciseConfigSectionLabel(text: 'تکرارها'),
              const SizedBox(height: 16),
              _buildRepPickers(draft),
              const SizedBox(height: 22),
              _buildExtraFields(draft),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseHeader(_ItemDraft draft) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            draft.exerciseName,
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.secondarySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${_setsCount.persianNumber} ست',
            style: const TextStyle(
              color: AppColors.secondaryDark,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepPickers(_ItemDraft draft) {
    return Column(
      children: List.generate(_setsCount, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == _setsCount - 1 ? 0 : 10),
          child: AppNumberPicker(
            label: 'ست ${(index + 1).persianNumber}',
            value: draft.reps[index],
            min: ExerciseConfigParser.minReps,
            max: ExerciseConfigParser.maxReps,
            onChanged: (value) => _onRepChanged(draft, index, value),
          ),
        );
      }),
    );
  }

  Widget _buildExtraFields(_ItemDraft draft) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ExerciseConfigSectionLabel(text: 'جزئیات بیشتر'),
        const SizedBox(height: 16),
        AppTextField(controller: draft.tempo, label: 'تمپو'),
        const SizedBox(height: 12),
        AppTextField(
          controller: draft.description,
          label: 'توضیح',
          maxLines: 2,
        ),
      ],
    );
  }
}

/// Mutable, per-exercise editing state. Identified by POSITION (not by
/// exercise id), so the same exercise appearing twice cannot collide.
class _ItemDraft {
  final String exerciseId;
  final String exerciseName;
  final List<int> reps;
  final TextEditingController tempo;
  final TextEditingController description;

  _ItemDraft({
    required this.exerciseId,
    required this.exerciseName,
    required this.reps,
    required String tempo,
    required String description,
  }) : tempo = TextEditingController(text: tempo),
       description = TextEditingController(text: description);

  ExerciseItemResult toResult() {
    return ExerciseItemResult(
      exerciseId: exerciseId,
      reps: reps.map((value) => value.toString()).toList(growable: false),
      tempo: ExerciseConfigParser.normalizeTempo(tempo.text),
      description: description.text.trim(),
    );
  }

  void dispose() {
    tempo.dispose();
    description.dispose();
  }
}
