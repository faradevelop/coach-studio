import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_shadows.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

/// The two primary actions, shown right under the greeting:
/// orange "create program" + indigo "add athlete".
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            label: 'ساخت برنامه',
            gradient: AppColors.primaryGradient,
            shadow: AppShadows.primaryGlow,
            onTap: () => context.goNamed(AppRouteNames.createWorkoutProgram),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionButton(
            label: 'افزودن ورزشکار',
            gradient: AppColors.accentGradient,
            shadow: AppShadows.accentGlow,
            onTap: () => context.pushNamed(AppRouteNames.createAthlete),
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final String label;
  final Gradient gradient;
  final List<BoxShadow> shadow;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.label,
    required this.gradient,
    required this.shadow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.lg - 2);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: radius,
        boxShadow: shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.transparent,
          child: SizedBox(
            height: 54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedAdd01,
                    size: 20,
                    color: AppColors.onPrimary,
                    strokeWidth: 2,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.button.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
