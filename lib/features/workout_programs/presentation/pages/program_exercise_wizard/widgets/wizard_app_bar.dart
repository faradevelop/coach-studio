import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_mini_button.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_state.dart';
import 'package:material_ui/material_ui.dart';

/// Not [InnerPagesAppBar]: the back button here must go through
/// `Navigator.maybePop` so the wizard's PopScope can step back instead of
/// leaving the page (go_router's `context.pop` would bypass it).
class WizardAppBar extends StatelessWidget {
  final WizardStep step;

  const WizardAppBar({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: MaxWidthBox(
        maxWidth: AppContentWidth.form,
        child: Row(
          children: [
            const SizedBox(width: 38), // balances the back button
            const Spacer(),
            Column(
              children: [
                Text('تمرین جدید', style: AppTextStyles.titleMedium),
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
            AppMiniButton.back(onTap: () => Navigator.of(context).maybePop()),
          ],
        ),
      ),
    );
  }
}
