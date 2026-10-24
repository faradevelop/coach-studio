import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
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
    return Stack(
      children: [
        const Positioned.fill(child: _DashboardBackdrop()),
        SafeArea(
          child: SingleChildScrollView(
            child: MaxWidthBox(
              maxWidth: AppContentWidth.shell,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DashboardHeader(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: DashboardQuickActions(),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: DashboardStatsSection(),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: DashboardProgramsOverview(),
                  ),
                  SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Static, blur-free background: two soft radial glows (orange + indigo)
/// over the flat page background. Cheap to paint and never rebuilt.
class _DashboardBackdrop extends StatelessWidget {
  const _DashboardBackdrop();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            PositionedDirectional(
              top: -140,
              start: -110,
              child: _Glow(color: AppColors.primary, size: 360),
            ),
            PositionedDirectional(
              top: -80,
              end: -150,
              child: _Glow(color: AppColors.accent, size: 360),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.20), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
