import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:coach_studio/features/dashboard/presentation/widgets/dashboard_programs_overview.dart';
import 'package:coach_studio/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:coach_studio/features/dashboard/presentation/widgets/dashboard_stats_section.dart';
import 'package:flutter/material.dart';

/// Top-level destination. Purely compositional: every section reads the
/// app-wide Cubits itself, so only the section whose state changed rebuilds.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 20, 14, 100),
        child: MaxWidthBox(
          maxWidth: AppContentWidth.detail,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DashboardHeader(),
              SizedBox(height: AppSpacing.lg),
              DashboardStatsSection(),
              SizedBox(height: AppSpacing.lg),
              DashboardQuickActions(),
              SizedBox(height: AppSpacing.lg),
              DashboardProgramsOverview(),
            ],
          ),
        ),
      ),
    );
  }
}
