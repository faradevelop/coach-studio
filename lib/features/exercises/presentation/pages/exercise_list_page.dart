import 'dart:async';

import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/app_error_state.dart';
import 'package:coach_studio/core/widgets/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/custom_search_bar.dart';
import 'package:coach_studio/core/widgets/delete_dialog.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/core/widgets/responsive/responsive_grid.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_state.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/empty_exercises.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/exercise_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ExerciseListPage extends StatefulWidget {
  const ExerciseListPage({super.key});

  @override
  State<ExerciseListPage> createState() => _ExerciseListPageState();
}

class _ExerciseListPageState extends State<ExerciseListPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final cubit = context.read<ExerciseCubit>();
      final s = value.trim();
      if (s == cubit.filter.search) return;
      cubit.applyFilter(cubit.filter.copyWith(search: s));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<AuthCubit, bool>(
      (cubit) => switch (cubit.state) {
        AuthAuthenticated(:final user) => user.isAdmin,
        _ => false,
      },
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: BlocBuilder<ExerciseCubit, ExerciseState>(
          builder: (context, state) {
            final filter = context.read<ExerciseCubit>().filter;
            final showSearchBar =
                state is ExerciseLoaded &&
                (state.exercises.isNotEmpty || !filter.isEmpty);
            return Column(
              children: [
                MaxWidthBox(
                  maxWidth: AppContentWidth.shell,
                  child: CustomAppBar(
                    showAddButton: isAdmin,
                    onPressed: () {
                      context.pushNamed(AppRouteNames.createExercise);
                    },
                    title: 'تمرین‌ها',
                  ),
                ),
                const SizedBox(height: 28),
                if (showSearchBar)
                  CustomSearchBar(
                    hint: 'جستجو...',
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),

                Expanded(
                  child: switch (state) {
                    ExerciseLoading() => Center(
                      child: LoadingAnimationWidget.hexagonDots(
                        color: AppColors.orange,
                        size: 40,
                      ),
                    ),

                    ExerciseLoaded(:final exercises) =>
                      exercises.isEmpty
                          ? (filter.isEmpty
                                ? EmptyExercises(addMessage: isAdmin)
                                : Center(
                                    child: Text(
                                      'تمرینی یافت نشد!',
                                      style: TextStyle(
                                        color: AppColors.charcoal.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 15,
                                      ),
                                    ),
                                  ))
                          : ResponsiveGrid(
                              breakpoints: const [
                                ResponsiveGridBreakpoint(
                                  minWidth: 0,
                                  columns: 1,
                                ),
                                ResponsiveGridBreakpoint(
                                  minWidth: 650,
                                  columns: 2,
                                ),
                                ResponsiveGridBreakpoint(
                                  minWidth: 1000,
                                  columns: 3,
                                ),
                              ],
                              itemExtent:
                                  120, // ExerciseCard's fixed 108px + its own 6+6 vertical margin
                              mainAxisSpacing: 4,
                              padding: const EdgeInsets.fromLTRB(0, 12, 0, 90),
                              itemCount: exercises.length,
                              itemBuilder: (context, index) {
                                final exercise = exercises[index];
                                return ExerciseCard(
                                  exercise: exercise,
                                  showActions: isAdmin,
                                  onEdit: () {
                                    context.pushNamed(
                                      AppRouteNames.editExercise,
                                      pathParameters: {
                                        'exerciseId': exercise.id,
                                      },
                                      extra: exercise,
                                    );
                                  },
                                  onDelete: () async {
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => DeleteDialog(
                                        itemName: exercise.name,
                                        title: 'تمرین',
                                      ),
                                    );

                                    if (result == true && context.mounted) {
                                      final success = await context
                                          .read<ExerciseCubit>()
                                          .deleteExercise(exercise.id);

                                      if (!success) {
                                        sl<AppNotification>().error(
                                          'حذف تمرین ناموفق بود.',
                                        );
                                        return;
                                      }

                                      sl<AppNotification>().success(
                                        'تمرین با موفقیت حذف شد.',
                                      );
                                    }
                                  },
                                );
                              },
                            ),

                    ExerciseError() => AppErrorState(
                      onRetry: () =>
                          context.read<ExerciseCubit>().loadExercises(),
                    ),

                    ExerciseInitial() => const SizedBox(),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
