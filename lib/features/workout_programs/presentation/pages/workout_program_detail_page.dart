import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/add_program_exercise_page.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/exercise_configuration_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutProgramDetailPage extends StatelessWidget {
  final WorkoutProgram program;

  const WorkoutProgramDetailPage({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProgramExerciseCubit>()..loadExercises(program.id),
      child: _WorkoutProgramDetailView(program: program),
    );
  }
}

class _WorkoutProgramDetailView extends StatelessWidget {
  final WorkoutProgram program;
  const _WorkoutProgramDetailView({required this.program});

  Map<int, List<ProgramExerciseDetails>> _groupByDay(
    List<ProgramExerciseDetails> exercises,
  ) {
    final map = <int, List<ProgramExerciseDetails>>{};

    for (final exercise in exercises) {
      map.putIfAbsent(exercise.programExercise.day, () => []);
      map[exercise.programExercise.day]!.add(exercise);
    }

    for (final list in map.values) {
      list.sort(
        (a, b) => a.programExercise.order.compareTo(b.programExercise.order),
      );
    }

    return map;
  }

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Exercise'),
          content: const Text('Are you sure?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () async {
                await context.read<ProgramExerciseCubit>().deleteExercise(id);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddProgramExercisePage(program: program),
                      ),
                    );
                  },
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

                    ProgramExerciseLoaded(:final exercises) =>
                      exercises.isEmpty
                          ? const Center(child: Text('No exercises added yet'))
                          : _buildExercisesByDay(context, exercises),

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

  Widget _buildExercisesByDay(
    BuildContext context,
    List<ProgramExerciseDetails> exercises,
  ) {
    final grouped = _groupByDay(exercises);

    return ListView(
      children: grouped.entries.map((entry) {
        final day = entry.key;

        final dayExercises = entry.value;

        return ExpansionTile(
          title: Text('Day $day'),

          children: dayExercises.map((item) {
            return ListTile(
              title: Text(item.exercise.name),

              subtitle: Text(
                '${item.programExercise.sets} sets | '
                '${item.programExercise.reps}',
              ),

              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExerciseConfigurationPage(
                            program: program,
                            exercise: item.exercise,
                            existingExercise: item.programExercise,
                          ),
                        ),
                      );
                      break;

                    case 'delete':
                      _showDeleteDialog(context, item.programExercise.id);
                      break;
                  }
                },

                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
