import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutProgramDetailPage extends StatelessWidget {
  final WorkoutProgram program;

  const WorkoutProgramDetailPage({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(program.title)),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text('Goal: ${program.goal.name}'),
            Text('Level: ${program.level.name}'),
            Text('Days: ${program.daysPerWeek}'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  'Exercises',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: BlocBuilder<ProgramExerciseCubit, ProgramExerciseState>(
                builder: (context, state) {
                  return switch (state) {
                    ProgramExerciseLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),

                    ProgramExerciseError(:final message) => Center(
                      child: Text(message),
                    ),

                    ProgramExerciseLoaded(
                      :final exercises,
                      :final isSubmitting,
                    ) =>
                      exercises.isEmpty
                          ? const Center(child: Text('No exercises added yet'))
                          : ListView.builder(
                              itemCount: exercises.length,
                              itemBuilder: (context, index) {
                                final item = exercises[index];

                                return ListTile(
                                  title: Text(item.exercise.name),
                                  subtitle: Text(
                                    '${item.programExercise.sets} sets | '
                                    '${item.programExercise.reps}',
                                  ),
                                );
                              },
                            ),

                    _ => const SizedBox(),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
