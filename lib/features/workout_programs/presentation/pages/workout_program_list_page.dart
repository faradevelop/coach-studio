import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/create_workout_program_page.dart';
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateWorkoutProgramPage()),
          );

          if (context.mounted) {
            context.read<WorkoutProgramCubit>().loadPrograms();
          }
        },
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

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),

                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => WorkoutProgramDetailPage(
                                    program: program,
                                  ),
                                ),
                              );
                            },

                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          program.title,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                      ),

                                      PopupMenuButton<String>(
                                        onSelected: (value) {
                                          switch (value) {
                                            case 'edit':
                                              // بعداً
                                              break;

                                            case 'delete':
                                              _showDeleteDialog(
                                                context,
                                                program.id,
                                              );
                                              break;
                                          }
                                        },

                                        itemBuilder: (_) => const [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Text('Edit'),
                                          ),

                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  Row(
                                    children: [
                                      _InfoChip(
                                        icon: Icons.flag,
                                        text: program.goal.name,
                                      ),

                                      const SizedBox(width: 8),
                                      _InfoChip(
                                        icon: Icons.bar_chart,
                                        text: program.level.name,
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  Text('${program.daysPerWeek} days / week'),
                                ],
                              ),
                            ),
                          ),
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

void _showDeleteDialog(BuildContext context, String id) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: const Text('Delete Program'),
        content: const Text('Are you sure you want to delete this program?'),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child: const Text('Cancel'),
          ),

          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<WorkoutProgramCubit>().deleteProgram(id);
            },

            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(text)],
      ),
    );
  }
}
