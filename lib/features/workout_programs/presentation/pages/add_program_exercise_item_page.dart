import 'dart:ui';

import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_configuration_args.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/custom_search_bar.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_draft.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddProgramExerciseItemPage extends StatefulWidget {
  final WorkoutProgram program;
  final ProgramExerciseDraft draft;

  const AddProgramExerciseItemPage({
    super.key,
    required this.program,
    required this.draft,
  });

  @override
  State<AddProgramExerciseItemPage> createState() =>
      _AddProgramExerciseItemPageState();
}

class _AddProgramExerciseItemPageState
    extends State<AddProgramExerciseItemPage> {
  final List<Exercise> _selectedExercises = [];
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _maxSelection {
    switch (widget.draft.trainingSystem) {
      case TrainingSystem.normal:
        return 1;
      case TrainingSystem.superSet:
        return 2;
    }
  }

  List<Exercise> _filterExercises(List<Exercise> exercises) {
    if (_query.trim().isEmpty) return exercises;

    final query = _query.trim().toLowerCase();
    return exercises.where((exercise) {
      return exercise.name.contains(query) ||
          exercise.targetMuscle.label.contains(query) ||
          exercise.equipment.label.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.bgColors,
            stops: AppColors.bgStops,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.teal.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selectedExercises.length}/$_maxSelection',
                        style: const TextStyle(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Text('انتخاب تمرین', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: 100,
                          decoration: BoxDecoration(
                            color: AppColors.orange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GlassyBackButton(onTap: () => context.pop()),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: CustomSearchBar(
                  hint: 'جستجو ...',
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() => _query = value);
                  },
                ),
              ),

              // Exercise list
              Expanded(
                child: BlocBuilder<ExerciseCubit, ExerciseState>(
                  builder: (context, state) {
                    return switch (state) {
                      ExerciseLoading() => Center(
                        child: LoadingAnimationWidget.hexagonDots(
                          color: AppColors.orange,
                          size: 40,
                        ),
                      ),
                      ExerciseError(:final message) => Center(
                        child: Text(
                          message,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                      ExerciseLoaded(:final exercises) => Builder(
                        builder: (_) {
                          final filtered = _filterExercises(exercises);

                          if (filtered.isEmpty) {
                            return Center(
                              child: Text(
                                'تمرینی پیدا نشد!',
                                style: AppTextStyles.subtitle,
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                            itemCount: filtered.length,
                            itemBuilder: (_, index) {
                              final exercise = filtered[index];
                              final isSelected = _selectedExercises.contains(
                                exercise,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedExercises.remove(exercise);
                                        return;
                                      }

                                      if (_selectedExercises.length >=
                                          _maxSelection) {
                                        sl<AppNotification>().warning(
                                          'فقط $_maxSelection تمرین می‌توانید انتخاب کنید.',
                                        );

                                        return;
                                      }

                                      _selectedExercises.add(exercise);
                                    });
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg - 4,
                                    ),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 12,
                                        sigmaY: 12,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.orange.withValues(
                                                  alpha: 0.18,
                                                )
                                              : Colors.white.withValues(
                                                  alpha: 0.40,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg - 4,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.orange.withValues(
                                                    alpha: 0.6,
                                                  )
                                                : AppColors.glassBorder,
                                            width: isSelected ? 1.5 : 1.1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Selection indicator
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? AppColors.orange
                                                    : Colors.white.withValues(
                                                        alpha: 0.5,
                                                      ),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? AppColors.orange
                                                      : AppColors.charcoal
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                ),
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check_rounded,
                                                      size: 16,
                                                      color: Colors.white,
                                                    )
                                                  : null,
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    exercise.name,
                                                    style: AppTextStyles
                                                        .titleMedium
                                                        .copyWith(fontSize: 15),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    '${exercise.targetMuscle} • ${exercise.equipment}',
                                                    style: AppTextStyles
                                                        .bodySmall
                                                        .copyWith(
                                                          color: AppColors
                                                              .charcoal
                                                              .withValues(
                                                                alpha: 0.6,
                                                              ),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      _ => const SizedBox(),
                    };
                  },
                ),
              ),

              // Continue button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: AppButton(
                  text: 'تایید و مرحله بعد',
                  onPressed: _selectedExercises.length != _maxSelection
                      ? null
                      : () {
                          context.pushReplacementNamed(
                            AppRouteNames.configureProgramExercise,
                            pathParameters: {'programId': widget.program.id},
                            extra: ProgramExerciseConfigurationArgs(
                              program: widget.program,
                              draft: widget.draft,
                              exercises: _selectedExercises,
                            ),
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
