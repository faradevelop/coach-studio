import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'widgets/wizard_app_bar.dart';
import 'widgets/wizard_configure_step.dart';
import 'widgets/wizard_day_step.dart';
import 'widgets/wizard_select_exercises_step.dart';

class ProgramExerciseWizardPage extends StatelessWidget {
  final String programId;
  final WorkoutProgram? seedProgram;
  final int? day;

  const ProgramExerciseWizardPage({
    super.key,
    required this.programId,
    this.day,
    this.seedProgram,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProgramExerciseWizardCubit(
        programId: programId,
        programExerciseCubit: context.read<ProgramExerciseCubit>(),
        day: day,
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
          return Scaffold(
            body: Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.orange,
                size: 40,
              ),
            ),
          );
        }

        return BlocConsumer<
          ProgramExerciseWizardCubit,
          ProgramExerciseWizardState
        >(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
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
                        WizardAppBar(step: wizardState.step),
                        Expanded(
                          child: _buildCurrentStep(
                            context,
                            program,
                            wizardState,
                          ),
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

  Widget _buildCurrentStep(
    BuildContext context,
    WorkoutProgram program,
    ProgramExerciseWizardState state,
  ) {
    return switch (state.step) {
      WizardStep.day => WizardDayStep(program: program, programDay: state.day),
      WizardStep.selectExercises => WizardSelectExercisesStep(),
      WizardStep.configure => const WizardConfigureStep(),
    };
  }
}
