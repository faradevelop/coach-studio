// lib/features/workout_programs/presentation/pages/exercise_configuration_page.dart

import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/feedback/app_loading_indicator.dart';
import 'package:coach_studio/core/widgets/navigation/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_item.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/exercise_config/exercise_config_form.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/exercise_config/exercise_config_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Edits an EXISTING ProgramExercise (create lives in
/// ProgramExerciseWizardPage). Data is resolved from
/// [ProgramExerciseCubit]'s loaded state via [programExerciseId]; the form
/// itself is the shared [ExerciseConfigForm].
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
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: AppLoadingIndicator()),
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
  bool _isSubmitting = false;

  ProgramExercise get _existing => widget.details.programExercise;

  ExerciseConfigInput _buildInput() {
    return ExerciseConfigInput(
      sets: _existing.sets,
      rest: _existing.rest,
      day: _existing.day,
      trainingSystem: _existing.trainingSystem,
      items: [
        for (final itemDetails in widget.details.items)
          ExerciseConfigItemInput(
            exerciseId: itemDetails.exercise.id,
            exerciseName: itemDetails.exercise.name,
            reps: itemDetails.item.reps,
            tempo: itemDetails.item.tempo,
            description: itemDetails.item.description ?? '',
          ),
      ],
    );
  }

  Future<void> _save(ExerciseConfigResult result) async {
    setState(() => _isSubmitting = true);

    try {
      final existingItems = widget.details.items;

      // The form preserves the input order, so results align by index.
      final items = [
        for (var i = 0; i < existingItems.length; i++)
          ProgramExerciseItem(
            id: existingItems[i].item.id,
            programExerciseId: _existing.id,
            exerciseId: existingItems[i].exercise.id,
            order: i + 1,
            reps: result.items[i].reps,
            tempo: result.items[i].tempo,
            description: result.items[i].description.isEmpty
                ? null
                : result.items[i].description,
          ),
      ];

      final updated = _existing.copyWith(
        sets: result.sets.toString(),
        rest: result.restSeconds.toString(),
        items: items,
      );

      final success = await context
          .read<ProgramExerciseCubit>()
          .updateProgramExercise(updated);

      if (!mounted) return;

      if (!success) {
        sl<AppNotification>().error('ویرایش تمرین ناموفق بود.');
        return;
      }

      sl<AppNotification>().success('تمرین با موفقیت ویرایش شد.');
      context.pop();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const MaxWidthBox(
              maxWidth: AppContentWidth.form,
              child: InnerPagesAppBar(
                rightButton: SizedBox(width: 40),
                title: 'ویرایش تمرین',
              ),
            ),
            Expanded(
              child: ExerciseConfigForm(
                input: _buildInput(),
                submitLabel: 'ویرایش',
                isSubmitting: _isSubmitting,
                onSubmit: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
