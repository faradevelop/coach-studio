import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/custom_search_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_filter_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
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
  String _query = '';

  List<Muscle> _muscles = const [];

  List<Exercise> _filterExercises(List<Exercise> exercises, String query) {
    if (query.trim().isEmpty) {
      return exercises;
    }

    final normalizedQuery = query.trim().toLowerCase();
    return exercises
        .where(
          (exercise) =>
              exercise.name.contains(normalizedQuery) ||
              exercise.equipment.label.contains(normalizedQuery),
        )
        .toList();
  }

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
    final exerciseCubit = context.read<ExerciseCubit>();

    await exerciseCubit.waitForExerciseMeta();
    if (!mounted) return;

    setState(() {
      _muscles = exerciseCubit.muscles;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadExerciseMeta();
  }

  @override
  void dispose() {
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
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
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
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      builder: (context, state) {
        return switch (state) {
          ExerciseLoading() => Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: AppColors.orange,
              size: 40,
            ),
          ),

          ExerciseError() => const Center(
            child: Text('خطا در بارگذاری تمرین‌ها'),
          ),

          ExerciseLoaded(:final exercises) => _buildLoadedExercises(
            context,
            exercises,
            wizardState,
          ),

          _ => const SizedBox(),
        };
      },
    );
  }

  Widget _buildLoadedExercises(
    BuildContext context,
    List<Exercise> exercises,
    ProgramExerciseWizardState wizardState,
  ) {
    final filter = context.watch<ExerciseFilterCubit>().state;
    final byFilter = filter.isEmpty
        ? exercises
        : exercises.where(filter.matches).toList();
    final filteredExercises = _filterExercises(byFilter, _query);

    if (filteredExercises.isEmpty) {
      return Center(
        child: Text('تمرینی پیدا نشد!', style: AppTextStyles.subtitle),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 20),
      itemCount: filteredExercises.length,
      itemBuilder: (_, index) {
        final exercise = filteredExercises[index];
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
