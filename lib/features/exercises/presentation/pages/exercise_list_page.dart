import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
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
          if (state is ExerciseLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ExerciseLoaded) {
            if (state.exercises.isEmpty) {
              return const Center(child: Text('No exercises found'));
            }

            return ListView.builder(
              itemCount: state.exercises.length,
              itemBuilder: (context, index) {
                final exercise = state.exercises[index];

                return ListTile(
                  title: Text(exercise.name),
                  subtitle: Text(exercise.targetMuscle),
                );
              },
            );
          }

          if (state is ExerciseError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
