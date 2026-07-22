import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/workout_program_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutProgramListPage extends StatelessWidget {
  const WorkoutProgramListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Programs')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Create Program'),
      ),

      body: BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
        builder: (context, state) {
          return switch (state) {
            WorkoutProgramInitial() => const SizedBox(),

            WorkoutProgramLoading() => const Center(
              child: CircularProgressIndicator(),
            ),

            WorkoutProgramLoaded(:final programs) =>
              programs.isEmpty
                  ? _EmptyProgramsState()
                  : ListView.builder(
                      itemCount: programs.length,

                      itemBuilder: (context, index) {
                        final program = programs[index];

                        return ListTile(
                          title: Text(program.title),
                          subtitle: Text(program.level.name),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    WorkoutProgramDetailPage(program: program),
                              ),
                            );
                          },
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

class _EmptyProgramsState extends StatelessWidget {
  const _EmptyProgramsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fitness_center, size: 64),
          const SizedBox(height: 16),

          Text(
            'No workout programs yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),
          const Text('Create your first program'),
        ],
      ),
    );
  }
}
