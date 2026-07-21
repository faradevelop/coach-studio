import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutProgramListPage extends StatelessWidget {
  const WorkoutProgramListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Programs')),

      body: BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
        builder: (context, state) {
          return switch (state) {
            WorkoutProgramInitial() => const SizedBox(),

            WorkoutProgramLoading() => const Center(
              child: CircularProgressIndicator(),
            ),

            WorkoutProgramLoaded(:final programs) => ListView.builder(
              itemCount: programs.length,

              itemBuilder: (context, index) {
                final program = programs[index];

                return ListTile(
                  title: Text(program.title),

                  subtitle: Text(program.level.name),
                );
              },
            ),

            WorkoutProgramError(:final message) => Center(child: Text(message)),
          };
        },
      ),
    );
  }
}
