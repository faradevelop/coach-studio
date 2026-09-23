import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_dropdown.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'wizard_common_widgets.dart';

class WizardDayStep extends StatelessWidget {
  final WorkoutProgram program;
  final int? programDay;

  const WizardDayStep({super.key, required this.program, this.programDay});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProgramExerciseWizardCubit>();
    final state = context.watch<ProgramExerciseWizardCubit>().state;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: MaxWidthBox(
        maxWidth: AppContentWidth.form,
        child: WizardGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppDropdown<int>(
                label: 'روز تمرین',
                value: programDay ?? state.day,
                items: List.generate(program.daysPerWeek, (index) => index + 1),
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
