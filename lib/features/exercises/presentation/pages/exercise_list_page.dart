import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/empty_exercises.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/exercise_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExerciseListPage extends StatelessWidget {
  const ExerciseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercises')),
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

                        return ExerciseTile(exercise: exercise);
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
