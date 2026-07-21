import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddProgramExercisePage extends StatelessWidget {
  final String programId;

  const AddProgramExercisePage({super.key, required this.programId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ExerciseCubit>()..loadExercises(),

      child: Scaffold(
        appBar: AppBar(title: const Text('Select Exercise')),

        body: BlocBuilder<ExerciseCubit, ExerciseState>(
          builder: (context, state) {
            return switch (state) {
              ExerciseLoading() => const Center(
                child: CircularProgressIndicator(),
              ),

              ExerciseLoaded(:final exercises) => ListView.builder(
                itemCount: exercises.length,

                itemBuilder: (_, index) {
                  final exercise = exercises[index];

                  return ListTile(
                    title: Text(exercise.name),

                    subtitle: Text(exercise.targetMuscle),

                    onTap: () {
                      // مرحله بعد
                    },
                  );
                },
              ),

              ExerciseError(:final message) => Center(child: Text(message)),

              _ => const SizedBox(),
            };
          },
        ),
      ),
    );
  }
}
