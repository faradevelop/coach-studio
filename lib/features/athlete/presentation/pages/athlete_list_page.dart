import 'dart:async';

import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/display/app_info_chip.dart';
import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
import 'package:coach_studio/core/widgets/inputs/custom_search_bar.dart';
import 'package:coach_studio/core/widgets/navigation/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/core/widgets/responsive/responsive_grid.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_summary.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_cubit.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_state.dart';
import 'package:coach_studio/features/athlete/presentation/widgets/athlete_card.dart';
import 'package:coach_studio/features/athlete/presentation/widgets/athlete_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AthleteListPage extends StatefulWidget {
  const AthleteListPage({super.key});

  @override
  State<AthleteListPage> createState() => _AthleteListPageState();
}

class _AthleteListPageState extends State<AthleteListPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final cubit = context.read<AthleteCubit>();
      final s = value.trim();
      if (s == cubit.filter.search) return;
      cubit.applyFilter(cubit.filter.copyWith(search: s));
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: BlocBuilder<AthleteCubit, AthleteState>(
          builder: (context, state) {
            final cubit = context.read<AthleteCubit>();
            final filter = cubit.filter;
            final showTools =
                state is AthleteLoaded &&
                (state.athletes.isNotEmpty || !filter.isDefault);

            return Column(
              children: [
                MaxWidthBox(
                  maxWidth: AppContentWidth.shell,
                  child: CustomAppBar(
                    onPressed: () =>
                        context.pushNamed(AppRouteNames.createAthlete),
                    title: 'ورزشکارها',
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (state is AthleteLoaded && state.summary != null) ...[
                  _SummaryRow(summary: state.summary!),
                  const SizedBox(height: 12),
                ],
                if (showTools) ...[
                  CustomSearchBar(
                    hint: 'جستجو...',
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: 10),
                  AthleteFilterBar(
                    filter: filter,
                    onChanged: cubit.applyFilter,
                  ),
                ],
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
                          ? (filter.isDefault
                                ? const _EmptyAthletes()
                                : const Center(
                                    child: Text(
                                      'ورزشکاری یافت نشد!',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ))
                          : RefreshIndicator(
                              onRefresh: cubit.refresh,
                              child: ResponsiveGrid(
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
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  0,
                                  12,
                                  0,
                                  90,
                                ),
                                itemCount: athletes.length,
                                itemBuilder: (context, index) {
                                  final athlete = athletes[index];
                                  return AthleteCard(
                                    athlete: athlete,
                                    onTap: () => context.pushNamed(
                                      AppRouteNames.athleteDetail,
                                      pathParameters: {'athleteId': athlete.id},
                                    ),
                                  );
                                },
                              ),
                            ),
                    AthleteError() => AppErrorState(
                      onRetry: cubit.loadAthletes,
                    ),
                    AthleteInitial() => const SizedBox(),
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

class _SummaryRow extends StatelessWidget {
  final AthleteSummary summary;
  const _SummaryRow({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          AppInfoChip(text: 'کل: ${summary.total}'),
          AppInfoChip(text: 'فعال: ${summary.active}'),
          AppInfoChip(text: 'بایگانی: ${summary.archived}'),
        ],
      ),
    );
  }
}

class _EmptyAthletes extends StatelessWidget {
  const _EmptyAthletes();

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
                icon: HugeIcons.strokeRoundedGymnastic,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('ورزشکاری وجود ندارد!', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'با کلیک روی  +  اولین ورزشکار را اضافه کنید',
              style: AppTextStyles.subtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
