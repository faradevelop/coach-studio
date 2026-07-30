import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/widgets/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/custom_search_bar.dart';
import 'package:coach_studio/core/widgets/delete_dialog.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/empty_exercises.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/exercise_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ExerciseListPage extends StatelessWidget {
  const ExerciseListPage({super.key});

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
              title: 'Exercises',
            ),
            SizedBox(height: 28),
            CustomSearchBar(hint: 'Search exercises...'),
            Expanded(
              child: BlocBuilder<ExerciseCubit, ExerciseState>(
                builder: (context, state) {
                  return switch (state) {
                    ExerciseLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),

                    ExerciseLoaded(:final exercises) =>
                      exercises.isEmpty
                          ? const EmptyExercises()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              itemCount: exercises.length,
                              itemBuilder: (context, index) {
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

                                      builder: (_) =>
                                          DeleteDialog(itemName: exercise.name),
                                    );

                                    if (result == true && context.mounted) {
                                      context
                                          .read<ExerciseCubit>()
                                          .deleteExercise(exercise.id);
                                    }
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
