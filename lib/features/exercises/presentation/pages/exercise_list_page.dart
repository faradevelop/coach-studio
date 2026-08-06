import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/custom_search_bar.dart';
import 'package:coach_studio/core/widgets/delete_dialog.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
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
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            CustomAppBar(
              onPressed: () {
                context.pushNamed(AppRouteNames.createExercise);
              },
              title: 'تمرین‌ها',
            ),
            SizedBox(height: 28),
            CustomSearchBar(
              hint: 'جستجو...',
              controller: _searchController,
              onChanged: (String value) {
                setState(() => _query = value);
              },
            ),
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

                    ExerciseLoaded(:final exercises) =>
                      exercises.isEmpty
                          ? const EmptyExercises()
                          : Builder(
                              builder: (_) {
                                final filtered = _filterExercises(exercises);

                                if (filtered.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'تمرینی یافت نشد!',
                                      style: TextStyle(
                                        color: AppColors.charcoal.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }
                                return ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  itemCount: filtered.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == filtered.length) {
                                      return SizedBox(height: 60);
                                    }
                                    final exercise = exercises[index];
                                    return ExerciseCard(
                                      exercise: exercise,
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
                                          context
                                              .read<ExerciseCubit>()
                                              .deleteExercise(exercise.id);
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            ),

                    ExerciseError(:final message) => Center(
                      child: Text(message),
                    ),

                    ExerciseInitial() => const SizedBox(),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
