import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const DashboardSectionHeader(title: 'دسترسی سریع'),
        const SizedBox(height: 12),
        AppButton(
          text: 'ایجاد برنامه',
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedTaskAdd01,
            size: 20,
            color: AppColors.onPrimary,
            strokeWidth: 1.8,
          ),
          onPressed: () =>
              context.pushNamed(AppRouteNames.createWorkoutProgram),
        ),
      ],
    );
  }
}
