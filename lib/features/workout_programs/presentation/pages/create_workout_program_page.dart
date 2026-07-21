import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/workout_program_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateWorkoutProgramPage extends StatelessWidget {
  const CreateWorkoutProgramPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Program')),

      body: WorkoutProgramForm(
        onSubmit: (program) async {
          final createdProgram = await context
              .read<WorkoutProgramCubit>()
              .addProgram(program);

          if (createdProgram != null && context.mounted) {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => BlocProvider.value(
            //       value: context.read<WorkoutProgramCubit>(),

            //       child: WorkoutProgramDetailPage(program: createdProgram),
            //     ),
            //   ),
            // );
          }
        },
      ),
    );
  }
}
