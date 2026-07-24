import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:coach_studio/features/exercises/presentation/pages/edit_exercise_page.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/delete_exercise_dialog.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/empty_exercises.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/exercise_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ExerciseListPage extends StatelessWidget {
  const ExerciseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed(AppRouteNames.createExercise);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
      ),
      body: Column(
        children: [
          _ExerciseHeader(),
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
                            padding: const EdgeInsets.all(16),
                            itemCount: exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = exercises[index];

                              return ExerciseCard(
                                exercise: exercise,
                                onEdit: () {
                                  context.pushNamed(
                                    AppRouteNames.editExercise,
                                    pathParameters: {'exerciseId': exercise.id},
                                    extra: exercise,
                                  );
                                },

                                onDelete: () async {
                                  final result = await showDialog<bool>(
                                    context: context,

                                    builder: (_) => DeleteExerciseDialog(
                                      exerciseName: exercise.name,
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
                          ),

                  ExerciseError(:final message) => Center(child: Text(message)),

                  ExerciseInitial() => const SizedBox(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseHeader extends StatelessWidget {
  const _ExerciseHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            'Manage your exercises',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 12),

          TextField(
            decoration: InputDecoration(
              hintText: 'Search exercises...',

              prefixIcon: const Icon(Icons.search),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
