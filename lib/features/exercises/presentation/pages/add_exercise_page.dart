import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/exercise_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddExercisePage extends StatelessWidget {
  const AddExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Exercise')),

      body: ExerciseForm(
        onSubmit: (exercise) async {
          await context.read<ExerciseCubit>().addExercise(exercise);

          if (context.mounted) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
