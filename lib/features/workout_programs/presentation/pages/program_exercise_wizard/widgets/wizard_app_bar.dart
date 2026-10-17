import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_state.dart';
import 'package:flutter/material.dart';

/// Not [InnerPagesAppBar]: the back button here must go through
/// `Navigator.maybePop` so the wizard's PopScope can step back instead of
/// leaving the page (go_router's `context.pop` would bypass it).
class WizardAppBar extends StatelessWidget {
  final WizardStep step;

  const WizardAppBar({super.key, required this.step});

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
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const Spacer(),
            GlassyBackButton(onTap: () => Navigator.of(context).maybePop()),
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
    final currentIndex = WizardStep.values.indexOf(currentStep);

    return Row(
      children: List.generate(WizardStep.values.length, (index) {
        final isActive = index <= currentIndex;

        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.primary : AppColors.outline,
            ),
          ),
        );
      }),
    );
  }
}
