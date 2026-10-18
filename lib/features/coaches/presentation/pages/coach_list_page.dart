import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/core/widgets/navigation/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/responsive/responsive_grid.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';
import 'package:coach_studio/features/coaches/presentation/cubit/coach_cubit.dart';
import 'package:coach_studio/features/coaches/presentation/cubit/coach_state.dart';
import 'package:coach_studio/features/coaches/presentation/widgets/coach_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CoachListPage extends StatelessWidget {
  const CoachListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            CustomAppBar(
              title: 'مربی‌ها',
              onPressed: () => context.pushNamed(AppRouteNames.createCoach),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: BlocBuilder<CoachCubit, CoachState>(
                builder: (context, state) => switch (state) {
                  CoachInitial() => const SizedBox(),
                  CoachLoading() => Center(
                    child: LoadingAnimationWidget.hexagonDots(
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                  CoachError() => AppErrorState(
                    onRetry: () => context.read<CoachCubit>().load(),
                  ),
                  CoachLoaded(:final coaches) =>
                    coaches.isEmpty
                        ? Center(
                            child: Text(
                              'مربی‌ای وجود ندارد!',
                              style: AppTextStyles.titleMedium,
                            ),
                          )
                        : ResponsiveGrid(
                            breakpoints: const [
                              ResponsiveGridBreakpoint(minWidth: 0, columns: 1),
                              ResponsiveGridBreakpoint(
                                minWidth: 700,
                                columns: 2,
                              ),
                              ResponsiveGridBreakpoint(
                                minWidth: 1100,
                                columns: 3,
                              ),
                            ],
                            itemExtent: 96,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 40),
                            itemCount: coaches.length,
                            itemBuilder: (context, i) => _CoachCard(
                              coach: coaches[i],
                              onTap: () => context.pushNamed(
                                AppRouteNames.coachDetail,
                                pathParameters: {'coachId': coaches[i].id},
                                extra: coaches[i],
                              ),
                            ),
                          ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  final AuthUser coach;
  final VoidCallback onTap;

  const _CoachCard({required this.coach, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coach.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  coach.email.englishNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          CoachStatusChip(isActive: coach.isActive),
        ],
      ),
    );
  }
}
