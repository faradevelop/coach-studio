import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_state.dart';
import 'package:coach_studio/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    // Creating exercises is admin-only (router redirect + ExercisePolicy),
    // so the action is not offered to coaches.
    final isAdmin = context.select<AuthCubit, bool>(
      (cubit) => switch (cubit.state) {
        AuthAuthenticated(:final user) => user.isAdmin,
        _ => false,
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DashboardSectionHeader(title: 'دسترسی سریع'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                label: 'ایجاد برنامه',
                icon: HugeIcons.strokeRoundedTaskAdd01,
                primary: true,
                onTap: () =>
                    context.pushNamed(AppRouteNames.createWorkoutProgram),
              ),
            ),
            if (isAdmin) ...[
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionTile(
                  label: 'افزودن تمرین',
                  icon: HugeIcons.strokeRoundedDumbbell01,
                  primary: false,
                  onTap: () => context.pushNamed(AppRouteNames.createExercise),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String label;
  final dynamic icon;
  final bool primary;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    final foreground = primary ? AppColors.onOrange : AppColors.orangeDark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: primary
            ? [
                BoxShadow(
                  color: AppColors.orange.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: primary
            ? AppColors.orange
            : Colors.white.withValues(alpha: 0.55),
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: primary
                  ? null
                  : Border.all(
                      color: AppColors.orange.withValues(alpha: 0.55),
                      width: 1.2,
                    ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: icon,
                  size: 20,
                  color: foreground,
                  strokeWidth: 1.8,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
