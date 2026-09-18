import 'dart:ui';

import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_error_state.dart';
import 'package:coach_studio/core/widgets/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/delete_dialog.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/core/widgets/responsive/responsive_grid.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/info_dialog.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/workout_program_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class WorkoutProgramListPage extends StatelessWidget {
  const WorkoutProgramListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WorkoutProgramListView();
  }
}

class _WorkoutProgramListView extends StatelessWidget {
  const _WorkoutProgramListView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: MaxWidthBox(
              maxWidth: AppContentWidth.shell,
              child: CustomAppBar(
                onPressed: () {
                  context.pushNamed(AppRouteNames.createWorkoutProgram);
                },
                title: 'برنامه‌های تمرینی',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg + 4),
          Expanded(
            child: BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
              builder: (context, state) {
                return switch (state) {
                  WorkoutProgramInitial() => const SizedBox(),

                  WorkoutProgramLoading() => Center(
                    child: LoadingAnimationWidget.hexagonDots(
                      color: AppColors.orange,
                      size: 40,
                    ),
                  ),

                  WorkoutProgramLoaded(:final programs) =>
                    programs.isEmpty
                        ? const _EmptyProgramsState()
                        : ResponsiveGrid(
                            breakpoints: const [
                              ResponsiveGridBreakpoint(minWidth: 0, columns: 1),
                              ResponsiveGridBreakpoint(
                                minWidth: 420,
                                columns: 2,
                              ),
                              ResponsiveGridBreakpoint(
                                minWidth: 650,
                                columns: 3,
                              ),
                              ResponsiveGridBreakpoint(
                                minWidth: 1000,
                                columns: 4,
                              ),
                            ],
                            itemExtent: 210,
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
                            itemCount: programs.length,
                            itemBuilder: (context, index) {
                              final program = programs[index];
                              return WorkoutProgramCard(
                                program: program,
                                onDelete: () async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => DeleteDialog(
                                      itemName: program.title,
                                      title: 'برنامه',
                                    ),
                                  );

                                  if (result == true && context.mounted) {
                                    final success = await context
                                        .read<WorkoutProgramCubit>()
                                        .deleteProgram(program.id);

                                    if (!success) {
                                      sl<AppNotification>().error(
                                        'حذف برنامه ناموفق بود.',
                                      );
                                      return;
                                    }
                                    sl<AppNotification>().success(
                                      'برنامه با موفقیت حذف شد.',
                                    );
                                  }
                                },
                                onCopy: () async {
                                  final result = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => InfoDialog(
                                      title: program.title,
                                      message:
                                          'برنامه "${program.title}" با نام "${program.title} (copy)" ذخیره خواهد شد.',
                                    ),
                                  );

                                  if (result == true && context.mounted) {
                                    final success = await context
                                        .read<WorkoutProgramCubit>()
                                        .duplicateProgram(program.id, '');

                                    if (!success) {
                                      sl<AppNotification>().error(
                                        'کپی برنامه ناموفق بود.',
                                      );
                                      return;
                                    }
                                    sl<AppNotification>().success(
                                      'برنامه با موفقیت کپی شد.',
                                    );
                                  }
                                },
                                onTap: () async {
                                  context.pushNamed(
                                    AppRouteNames.workoutProgramDetail,
                                    pathParameters: {'programId': program.id},
                                    extra: program,
                                  );
                                },
                              );
                            },
                          ),
                  WorkoutProgramError() => AppErrorState(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProgramsState extends StatelessWidget {
  const _EmptyProgramsState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1.2,
                    ),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedClipboard,
                    size: 40,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('برنامه‌ای وجود ندارد!', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'با کلیک روی  +  اولین برنامه را ایجاد کنید',
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
