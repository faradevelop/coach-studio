import 'dart:async';

import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
import 'package:coach_studio/core/widgets/inputs/custom_search_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise_filter.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_filter_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_state.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/exercise_filter_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'exercise_select_tile.dart';

class WizardSelectExercisesStep extends StatefulWidget {
  const WizardSelectExercisesStep({super.key});

  @override
  State<WizardSelectExercisesStep> createState() =>
      _WizardSelectExercisesStepState();
}

class _WizardSelectExercisesStepState extends State<WizardSelectExercisesStep> {
  /// Search (44) + Spacing (12) + Filter (34) + Bottom Spacing (12)
  static const double _headerExtent = 102;

  ///Selected exercises bar (content 34 + top/bottom spacing)
  static const double _pinnedExtent = 48;

  static const double _hPadding = 20;

  final _searchController = TextEditingController();
  final _filterCubit = ExerciseFilterCubit();

  List<Muscle> _muscles = const [];

  static const _searchDebounce = Duration(milliseconds: 400);
  Timer? _debounce;
  int _requestId = 0;
  String _lastSearch = '';
  List<Exercise> _exercises = const [];
  bool _isLoading = true;
  bool _hasError = false;

  bool _isExerciseSelected(
    Exercise exercise,
    ProgramExerciseWizardState state,
  ) {
    return state.selectedExercises.any(
      (selected) => selected.id == exercise.id,
    );
  }

  void _handleExerciseTap(
    BuildContext context,
    Exercise exercise,
    ProgramExerciseWizardState state,
  ) {
    final cubit = context.read<ProgramExerciseWizardCubit>();
    final isSelected = _isExerciseSelected(exercise, state);

    if (!isSelected && state.selectedExercises.length >= state.maxSelection) {
      sl<AppNotification>().warning(
        'حداکثر ${state.maxSelection.persianNumber} تمرین می‌توانید انتخاب کنید.',
      );
      return;
    }

    cubit.toggleExerciseSelection(exercise);
  }

  Future<void> _loadExerciseMeta() async {
    final cubit = context.read<ExerciseCubit>();
    final ok = await cubit.ensureMetaLoaded();
    if (!mounted) return;
    if (!ok) {
      sl<AppNotification>().warning('بارگذاری فیلتر عضلات ناموفق بود.');
      return;
    }
    setState(() => _muscles = cubit.muscles);
  }

  Future<void> _fetch(ExerciseFilter filter) async {
    final requestId = ++_requestId;
    final cubit = context.read<ExerciseCubit>();
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final result = await cubit.searchExercises(filter);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _exercises = result;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _onFilterChanged(ExerciseFilter filter) {
    _debounce?.cancel();
    if (filter.search != _lastSearch) {
      _lastSearch = filter.search;
      _debounce = Timer(_searchDebounce, () => _fetch(filter));
    } else {
      _fetch(filter); // chip change: no debounce
    }
  }

  @override
  void initState() {
    super.initState();
    _loadExerciseMeta();
    _fetch(const ExerciseFilter());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _filterCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wizardCubit = context.read<ProgramExerciseWizardCubit>();
    final wizardState = context.watch<ProgramExerciseWizardCubit>().state;

    return BlocProvider<ExerciseFilterCubit>.value(
      value: _filterCubit,
      child: BlocListener<ExerciseFilterCubit, ExerciseFilter>(
        listener: (_, f) => _onFilterChanged(f),
        child: MaxWidthBox(
          maxWidth: AppContentWidth.form,
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // 1) Search + Filter: they move up and fade out on scroll
                    SliverPersistentHeader(
                      pinned: false,
                      delegate: _CollapsingHeaderDelegate(
                        extent: _headerExtent,
                        child: _buildCollapsingHeaderContent(),
                      ),
                    ),

                    // 2) Selected exercises bar: pinned below the stepper
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _PinnedHeaderDelegate(
                        extent: _pinnedExtent,
                        child: _buildSelectedBar(wizardState),
                      ),
                    ),

                    // 3) Exercises list (or loading/error/empty states)
                    ..._buildExerciseSlivers(context, wizardState),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(_hPadding, 8, _hPadding, 20),
                child: AppButton(
                  text: 'تایید و مرحله بعد',
                  onPressed: wizardState.canProceedToConfigure
                      ? wizardCubit.goToConfigure
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── Collapsing header ─────────────────────────

  Widget _buildCollapsingHeaderContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _hPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomSearchBar(
              hint: 'جستجو ...',
              controller: _searchController,
              onChanged: _filterCubit.applySearch,
            ),
          ),
          ExerciseFilterBar(availableMuscles: _muscles),
        ],
      ),
    );
  }

  // ───────────────────────── Pinned selected bar ─────────────────────────

  Widget _buildSelectedBar(ProgramExerciseWizardState wizardState) {
    return Container(
      color: AppColors.background,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: _hPadding),
      child: SizedBox(
        height: 34,
        child: Row(
          children: [
            Container(
              height: 30,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.secondarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '${wizardState.selectedExercises.length.persianNumber}/${wizardState.maxSelection.persianNumber}',
                  style: const TextStyle(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                ),
              ),
            ),
            if (wizardState.selectedExercises.isNotEmpty) ...[
              const SizedBox(width: 10),
              Expanded(child: _buildSelectedExercises(wizardState)),
            ],
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Exercise list slivers ─────────────────────────

  List<Widget> _buildExerciseSlivers(
    BuildContext context,
    ProgramExerciseWizardState wizardState,
  ) {
    if (_hasError) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppErrorState(onRetry: () => _fetch(_filterCubit.state)),
        ),
      ];
    }

    if (_isLoading && _exercises.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: AppColors.primary,
              size: 40,
            ),
          ),
        ),
      ];
    }

    if (_exercises.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text('تمرینی پیدا نشد!', style: AppTextStyles.subtitle),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(_hPadding, 4, _hPadding, 20),
        sliver: SliverList.builder(
          itemCount: _exercises.length,
          itemBuilder: (_, index) {
            final exercise = _exercises[index];
            final isSelected = _isExerciseSelected(exercise, wizardState);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _handleExerciseTap(context, exercise, wizardState),
                child: ExerciseSelectTile(
                  exercise: exercise,
                  isSelected: isSelected,
                ),
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildSelectedExercises(ProgramExerciseWizardState wizardState) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: wizardState.selectedExercises.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final exercise = wizardState.selectedExercises[index];
          return Container(
            constraints: const BoxConstraints(maxWidth: 220),
            padding: const EdgeInsetsDirectional.only(start: 12, end: 6),
            decoration: BoxDecoration(
              color: AppColors.secondarySoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    exercise.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () => context
                        .read<ProgramExerciseWizardCubit>()
                        .toggleExerciseSelection(exercise),
                    tooltip: 'حذف',
                    icon: const Icon(Icons.close_rounded, size: 12),
                    color: AppColors.onSecondary,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints.tightFor(
                      width: 26,
                      height: 26,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Header that shrinks on scroll (height = 0) while fading out simultaneously.
///
/// The content is anchored to the "bottom" of the box; therefore, when the height decreases,
/// the content is clipped from the top.
class _CollapsingHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double extent;
  final Widget child;

  const _CollapsingHeaderDelegate({required this.extent, required this.child});

  @override
  double get minExtent => 0;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / extent).clamp(0.0, 1.0);
    // It fades out slightly faster than it collapses, so it looks smoother.
    final opacity = (1.0 - progress * 1.4).clamp(0.0, 1.0);

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.bottomCenter,
        minHeight: 0,
        maxHeight: extent,
        child: IgnorePointer(
          ignoring: progress >= 1.0,
          child: Opacity(
            opacity: opacity,
            child: SizedBox(height: extent, child: child),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CollapsingHeaderDelegate oldDelegate) => true;
}

/// Fixed (pinned) header with a constant height.
class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double extent;
  final Widget child;

  const _PinnedHeaderDelegate({required this.extent, required this.child});

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: extent, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedHeaderDelegate oldDelegate) => true;
}
