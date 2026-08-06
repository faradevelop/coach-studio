import 'dart:ui';
import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_configuration_args.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
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

  static const Color _orange = Color(0xFFFF6B35);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _charcoal = Color(0xFF2D2D2D);

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

    final query = _query.toLowerCase();
    return exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(query) ||
          exercise.targetMuscle.toLowerCase().contains(query) ||
          exercise.equipment.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF9A5A),
              Color(0xFFFFC9A0),
              Color(0xFFFFF0E0),
              _cream,
            ],
            stops: [0.0, 0.18, 0.45, 1.0],
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
                        color: _cream.withValues(alpha: 0.70),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selectedExercises.length}/$_maxSelection',
                        style: const TextStyle(
                          color: _orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        const Text(
                          'انتخاب تمرین',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _charcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: 100,
                          decoration: BoxDecoration(
                            color: _orange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: _charcoal,
                          ),
                        ),
                      ),
                    ),
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

              // لیست تمرین‌ها
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
                          style: const TextStyle(color: _charcoal),
                        ),
                      ),
                      ExerciseLoaded(:final exercises) => Builder(
                        builder: (_) {
                          final filtered = _filterExercises(exercises);

                          if (filtered.isEmpty) {
                            return Center(
                              child: Text(
                                'تمرینی پیدا نشد!',
                                style: TextStyle(
                                  color: _charcoal.withValues(alpha: 0.6),
                                  fontSize: 15,
                                ),
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'فقط $_maxSelection تمرین میتوانید انتخاب کنید.',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        return;
                                      }

                                      _selectedExercises.add(exercise);
                                    });
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
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
                                              ? _orange.withValues(alpha: 0.18)
                                              : Colors.white.withValues(
                                                  alpha: 0.40,
                                                ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? _orange.withValues(alpha: 0.6)
                                                : Colors.white.withValues(
                                                    alpha: 0.55,
                                                  ),
                                            width: isSelected ? 1.5 : 1.1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // آیکون انتخاب
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? _orange
                                                    : Colors.white.withValues(
                                                        alpha: 0.5,
                                                      ),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? _orange
                                                      : _charcoal.withValues(
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
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: _charcoal,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 3),
                                                  Text(
                                                    '${exercise.targetMuscle} • ${exercise.equipment}',
                                                    style: TextStyle(
                                                      fontSize: 12.5,
                                                      color: _charcoal
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

              // دکمه Configure
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
