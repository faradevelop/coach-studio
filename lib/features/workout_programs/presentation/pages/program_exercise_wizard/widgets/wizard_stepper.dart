import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_state.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WizardStepper extends StatelessWidget {
  final WizardStep step;

  const WizardStepper({super.key, required this.step});

  static const _titles = <WizardStep, String>{
    WizardStep.day: 'روز و سیستم',
    WizardStep.selectExercises: 'انتخاب حرکت',
    WizardStep.configure: 'تنظیم تمرین',
  };

  static const _icons = <WizardStep, List<List<dynamic>>>{
    WizardStep.day: HugeIcons.strokeRoundedCalendar05,
    WizardStep.selectExercises: HugeIcons.strokeRoundedWorkoutStretching,
    WizardStep.configure: HugeIcons.strokeRoundedSettings05,
  };

  @override
  Widget build(BuildContext context) {
    final activeIndex = step.index;
    final theme = Theme.of(context);

    return MaxWidthBox(
      maxWidth: AppContentWidth.form,
      child: Container(
        height: 110,
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Theme(
          data: theme.copyWith(
            canvasColor: Colors.transparent,
            colorScheme: theme.colorScheme.copyWith(
              surface: Colors.transparent,
            ),
          ),
          child: Stepper(
            type: StepperType.horizontal,
            physics: BouncingScrollPhysics(),
            currentStep: activeIndex,
            elevation: 0,
            margin: EdgeInsets.zero,
            headerPadding: const EdgeInsets.symmetric(horizontal: 20),
            contentPadding: EdgeInsets.zero,
            stepIconWidth: 36,
            stepIconHeight: 36,
            stepIconMargin: EdgeInsets.zero,
            connectorThickness: 1,
            onStepTapped: (index) {
              if (index < activeIndex) {
                context.read<ProgramExerciseWizardCubit>().goToStep(
                  WizardStep.values[index],
                );
              }
            },
            controlsBuilder: (context, details) {
              return const SizedBox.shrink();
            },

            stepIconBuilder: (index, state) {
              final isCompleted = index < activeIndex;
              final icon = isCompleted
                  ? HugeIcons.strokeRoundedTick02
                  : _icons[WizardStep.values[index]]!;

              return HugeIcon(
                icon: icon,
                size: 20,
                color: isCompleted
                    ? AppColors.onPrimary
                    : index == activeIndex
                    ? AppColors.accent
                    : AppColors.textMuted,
              );
            },

            steps: [
              for (final s in WizardStep.values)
                _buildStep(step: s, activeIndex: activeIndex),
            ],
          ),
        ),
      ),
    );
  }

  Step _buildStep({required WizardStep step, required int activeIndex}) {
    final index = step.index;
    final isCompleted = index < activeIndex;
    final isCurrent = index == activeIndex;
    final isActive = index <= activeIndex;

    final backgroundColor = isCompleted
        ? AppColors.accent
        : isCurrent
        ? AppColors.accent.withValues(alpha: 0.2)
        : AppColors.surface;

    final borderColor = isActive ? Colors.transparent : AppColors.outline;

    return Step(
      title: const SizedBox.shrink(),
      label: Text(
        _titles[step]!,
        style: AppTextStyles.caption.copyWith(
          fontSize: 11,
          fontWeight: isCurrent ? FontWeight.w500 : FontWeight.w400,
          color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          height: 2.5,
        ),
      ),
      content: const SizedBox.shrink(),
      isActive: isActive,
      state: isCompleted
          ? StepState.complete
          : isCurrent
          ? StepState.indexed
          : StepState.disabled,
      stepStyle: StepStyle(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.2),
        connectorColor: isCompleted ? AppColors.accent : AppColors.outline,
        connectorThickness: 1.5,
      ),
    );
  }
}
