import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/exercise_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditExercisePage extends StatelessWidget {
  final ExerciseModel exercise;

  const EditExercisePage({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Exercise')),

      body: BlocBuilder<ExerciseCubit, ExerciseState>(
        builder: (context, state) {
          final isLoading = state is ExerciseLoaded && state.isSubmitting;
          return ExerciseForm(
            initialExercise: exercise,
            isLoading: isLoading,
            onSubmit: (updatedExercise) async {
              await context.read<ExerciseCubit>().updateExercise(
                updatedExercise,
              );

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          );
        },
      ),
    );
  }
}
