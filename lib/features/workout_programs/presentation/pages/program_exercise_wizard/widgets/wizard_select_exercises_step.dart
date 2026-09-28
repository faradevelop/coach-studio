import 'dart:async';

import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_error_state.dart';
import 'package:coach_studio/core/widgets/custom_search_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise_filter.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_filter_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_wizard_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/program_exercise_wizard/widgets/exercise_filter_bar.dart';
import 'package:flutter/material.dart';
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
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: MaxWidthBox(
            maxWidth: AppContentWidth.form,
            child: Column(
              children: [
                _buildSearchHeader(wizardState),
                const SizedBox(height: 10),
                ExerciseFilterBar(availableMuscles: _muscles),
                const SizedBox(height: 10),
                Expanded(child: _buildExerciseList(context, wizardState)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
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
      ),
    );
  }

  Widget _buildSearchHeader(ProgramExerciseWizardState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: CustomSearchBar(
              hint: 'جستجو ...',
              controller: _searchController,
              onChanged: _filterCubit.applySearch,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${state.selectedExercises.length.persianNumber}/${state.maxSelection.persianNumber}',
              style: const TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(
    BuildContext context,
    ProgramExerciseWizardState wizardState,
  ) {
    if (_hasError) {
      return AppErrorState(onRetry: () => _fetch(_filterCubit.state));
    }
    if (_isLoading && _exercises.isEmpty) {
      return Center(
        child: LoadingAnimationWidget.hexagonDots(
          color: AppColors.orange,
          size: 40,
        ),
      );
    }
    if (_exercises.isEmpty) {
      return Center(
        child: Text('تمرینی پیدا نشد!', style: AppTextStyles.subtitle),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 20),
      itemCount: _exercises.length,
      itemBuilder: (_, index) {
        final exercise = _exercises[index];
        final isSelected = _isExerciseSelected(exercise, wizardState);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () {
              _handleExerciseTap(context, exercise, wizardState);
            },
            child: ExerciseSelectTile(
              exercise: exercise,
              isSelected: isSelected,
            ),
          ),
        );
      },
    );
  }
}
