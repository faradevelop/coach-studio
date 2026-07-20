import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:coach_studio/features/exercises/presentation/pages/add_exercise_page.dart';
import 'package:coach_studio/features/exercises/presentation/pages/edit_exercise_page.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/delete_exercise_dialog.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/empty_exercises.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/exercise_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExerciseListPage extends StatelessWidget {
  const ExerciseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ExerciseCubit>(),
                child: const AddExercisePage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ExerciseCubit, ExerciseState>(
        builder: (context, state) {
          return switch (state) {
            ExerciseLoading() => const Center(
              child: CircularProgressIndicator(),
            ),

            ExerciseLoaded(:final exercises) =>
              exercises.isEmpty
                  ? const EmptyExercises()
                  : ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];

                        return ExerciseCard(
                          exercise: exercise,
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<ExerciseCubit>(),
                                  child: EditExercisePage(exercise: exercise),
                                ),
                              ),
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
                              context.read<ExerciseCubit>().deleteExercise(
                                exercise.id,
                              );
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
    );
  }
}
