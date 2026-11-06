import 'dart:async';

import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/dialogs/delete_dialog.dart';
import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
import 'package:coach_studio/core/widgets/inputs/custom_search_bar.dart';
import 'package:coach_studio/core/widgets/navigation/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/navigation/custom_tab_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/core/widgets/responsive/responsive_grid.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_filter.dart';
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

class _WorkoutProgramListView extends StatefulWidget {
  const _WorkoutProgramListView();

  @override
  State<_WorkoutProgramListView> createState() =>
      _WorkoutProgramListViewState();
}

class _WorkoutProgramListViewState extends State<_WorkoutProgramListView> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // The cubit is app-wide, so the applied filter outlives this page.
    _searchController = TextEditingController(
      text: context.read<WorkoutProgramCubit>().filter.search,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _apply(WorkoutProgramFilter filter) async {
    final ok = await context.read<WorkoutProgramCubit>().applyFilter(filter);
    if (!mounted || ok) return;
    sl<AppNotification>().error('جستجوی برنامه‌ها ناموفق بود.');
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final cubit = context.read<WorkoutProgramCubit>();
      final search = value.trim();
      if (search == cubit.filter.search) return;
      _apply(cubit.filter.copyWith(search: search));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
        builder: (context, state) {
          final filter = context.read<WorkoutProgramCubit>().filter;

          final showTools =
              state is WorkoutProgramLoaded && state.programs.isNotEmpty;

          return Column(
            children: [
              // Always visible AppBar
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

              Expanded(
                child: NestedScrollView(
                  floatHeaderSlivers: false,
                  physics: const ClampingScrollPhysics(),

                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      if (showTools) ...[
                        // SearchBar: collapses and fades out
                        SliverPersistentHeader(
                          pinned: false,
                          delegate: _SearchBarDelegate(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                          ),
                        ),

                        // TabBar: stays at the top
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _PinnedTabBarDelegate(
                            filter: filter,
                            onTabSelected: (index) {
                              _apply(
                                filter.copyWith(
                                  status: ProgramStatusFilter.values[index],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ];
                  },

                  body: _buildBody(context, state, filter),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WorkoutProgramState state,
    WorkoutProgramFilter filter,
  ) {
    return switch (state) {
      WorkoutProgramInitial() => const SizedBox(),

      WorkoutProgramLoading() => Center(
        child: LoadingAnimationWidget.hexagonDots(
          color: AppColors.primary,
          size: 40,
        ),
      ),

      WorkoutProgramLoaded(:final programs, :final visiblePrograms) =>
        programs.isEmpty
            ? const _EmptyProgramsState()
            : visiblePrograms.isEmpty
            ? Center(
                child: Text(
                  'برنامه‌ای یافت نشد!',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 15),
                ),
              )
            : _buildGrid(context, visiblePrograms),

      WorkoutProgramError() => AppErrorState(
        onRetry: () => context.read<WorkoutProgramCubit>().loadPrograms(),
      ),
    };
  }

  Widget _buildGrid(BuildContext context, List<dynamic> programs) {
    return ResponsiveGrid(
      breakpoints: const [
        ResponsiveGridBreakpoint(minWidth: 0, columns: 1),
        ResponsiveGridBreakpoint(minWidth: 420, columns: 2),
        ResponsiveGridBreakpoint(minWidth: 650, columns: 3),
        ResponsiveGridBreakpoint(minWidth: 1000, columns: 4),
      ],
      itemExtent: 210,
      padding: const EdgeInsets.fromLTRB(14, 20, 14, 100),
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        return WorkoutProgramCard(
          program: program,
          onDelete: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (_) =>
                  DeleteDialog(itemName: program.title, title: 'برنامه'),
            );

            if (result == true && context.mounted) {
              final success = await context
                  .read<WorkoutProgramCubit>()
                  .deleteProgram(program.id);

              if (!success) {
                sl<AppNotification>().error('حذف برنامه ناموفق بود.');
                return;
              }
              sl<AppNotification>().success('برنامه با موفقیت حذف شد.');
            }
          },
          onCopy: () async {
            final result = await showDialog<bool>(
              context: context,
              builder: (_) => InfoDialog(
                title: program.title,
                message: 'یک کپی از برنامه "${program.title}" ساخته خواهد شد.',
              ),
            );

            if (result == true && context.mounted) {
              final success = await context
                  .read<WorkoutProgramCubit>()
                  .duplicateProgram(program.id, '');

              if (!success) {
                sl<AppNotification>().error('کپی برنامه ناموفق بود.');
                return;
              }
              sl<AppNotification>().success('برنامه با موفقیت کپی شد.');
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
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedClipboard,
                size: 40,
                color: AppColors.primary,
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

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBarDelegate({required this.controller, required this.onChanged});

  @override
  double get minExtent => 0;

  @override
  double get maxExtent => 72;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / maxExtent).clamp(0.0, 1.0);

    return ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 1.0 - progress,
        child: Opacity(
          opacity: 1.0 - progress,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: CustomSearchBar(
              hint: 'جستجوی برنامه یا ورزشکار...',
              controller: controller,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SearchBarDelegate oldDelegate) {
    return oldDelegate.controller != controller ||
        oldDelegate.onChanged != onChanged;
  }
}

class _PinnedTabBarDelegate extends SliverPersistentHeaderDelegate {
  final WorkoutProgramFilter filter;
  final ValueChanged<int> onTabSelected;

  const _PinnedTabBarDelegate({
    required this.filter,
    required this.onTabSelected,
  });

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      child: CustomTabBar(
        height: 40,
        tabs: ProgramStatusFilter.values.map((s) => s.label).toList(),
        selectedIndex: filter.status.index,
        onTabSelected: onTabSelected,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedTabBarDelegate oldDelegate) {
    return oldDelegate.filter != filter ||
        oldDelegate.onTabSelected != onTabSelected;
  }
}
