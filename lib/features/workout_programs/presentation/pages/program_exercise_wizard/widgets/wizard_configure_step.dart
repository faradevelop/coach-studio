import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/exercise_config/exercise_config_form.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/exercise_config/exercise_config_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Step 3 of the add-exercise wizard.
///
/// Pure adapter: maps [ProgramExerciseWizardState] into the shared
/// [ExerciseConfigForm] and persists its result through the wizard cubit.
class WizardConfigureStep extends StatelessWidget {
  const WizardConfigureStep({super.key});

  ExerciseConfigInput _buildInput(ProgramExerciseWizardState state) {
    return ExerciseConfigInput(
      sets: state.sets,
      rest: state.rest,
      day: state.day,
      trainingSystem: state.trainingSystem,
      items: [
        for (final exercise in state.selectedExercises)
          _buildItemInput(
            exercise.id,
            exercise.name,
            state.itemConfigs[exercise.id] ?? const ExerciseItemConfig(),
          ),
      ],
    );
  }

  ExerciseConfigItemInput _buildItemInput(
    String id,
    String name,
    ExerciseItemConfig config,
  ) {
    return ExerciseConfigItemInput(
      exerciseId: id,
      exerciseName: name,
      reps: config.reps,
      tempo: config.tempo,
      description: config.description,
    );
  }

  Future<void> _submit(
    BuildContext context,
    ExerciseConfigResult result,
  ) async {
    final cubit = context.read<ProgramExerciseWizardCubit>();

    cubit.setSets(result.sets.toString());
    cubit.setRest(result.restSeconds.toString());

    for (final item in result.items) {
      cubit.updateItemConfig(
        item.exerciseId,
        reps: item.reps,
        tempo: item.tempo,
        description: item.description,
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
    final state = context.watch<ProgramExerciseWizardCubit>().state;

    return ExerciseConfigForm(
      input: _buildInput(state),
      submitLabel: 'تأیید و ذخیره',
      isSubmitting: state.isSubmitting,
      onSubmit: (result) => _submit(context, result),
    );
  }
}
