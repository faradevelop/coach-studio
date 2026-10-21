import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
import 'package:coach_studio/core/widgets/inputs/custom_search_bar.dart';
import 'package:coach_studio/core/widgets/navigation/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/core/widgets/responsive/responsive_grid.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_cubit.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_state.dart';
import 'package:coach_studio/features/athlete/presentation/widgets/athlete_card.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AthleteListPage extends StatefulWidget {
  const AthleteListPage({super.key});

  @override
  State<AthleteListPage> createState() => _AthleteListPageState();
}

class _AthleteListPageState extends State<AthleteListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider<AthleteCubit>(
        create: (context) => sl<AthleteCubit>(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: BlocBuilder<AthleteCubit, AthleteState>(
            builder: (context, state) {
              final showSearchBar = true;
              final filter = List.empty();
              return Column(
                children: [
                  MaxWidthBox(
                    maxWidth: AppContentWidth.shell,
                    child: CustomAppBar(
                      onPressed: () {
                        //TODO
                        //go to create athlete page
                      },
                      title: 'ورزشکارها',
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (showSearchBar)
                    CustomSearchBar(
                      hint: 'جستجو...',
                      controller: _searchController,
                      onChanged: (value) {},
                    ),

                  Expanded(
                    child: switch (state) {
                      AthleteLoading() => Center(
                        child: LoadingAnimationWidget.hexagonDots(
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),

                      AthleteLoaded(:final athletes) =>
                        athletes.isEmpty
                            ? (filter.isEmpty
                                  ? AppSurface(
                                      child: Text('ورزشکاری وجود ندارد'),
                                    )
                                  : const Center(
                                      child: Text(
                                        'ورزشکار یافت نشد!',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
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
                                itemExtent: 120,
                                mainAxisSpacing: 4,
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  12,
                                  0,
                                  90,
                                ),
                                itemCount: athletes.length,
                                itemBuilder: (context, index) {
                                  final athlete = athletes[index];
                                  return AthleteCard(athlete: athlete);
                                },
                              ),
                      AthleteError() => AppErrorState(
                        onRetry: () =>
                            context.read<ExerciseCubit>().loadExercises(),
                      ),

                      AthleteInitial() => const SizedBox(),
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
