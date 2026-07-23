import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_draft.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/exercise_configuration_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddProgramExercisePage extends StatefulWidget {
  final WorkoutProgram program;
  final ProgramExerciseDraft draft;

  const AddProgramExercisePage({
    super.key,
    required this.program,
    required this.draft,
  });

  @override
  State<AddProgramExercisePage> createState() => _AddProgramExercisePageState();
}

class _AddProgramExercisePageState extends State<AddProgramExercisePage> {
  final List<Exercise> _selectedExercises = [];

  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _maxSelection {
    switch (widget.draft.trainingSystem) {
      case TrainingSystem.normal:
        return 1;
      case TrainingSystem.superSet:
        return 2;
    }
  }

  List<Exercise> _filterExercises(List<Exercise> exercises) {
    if (_query.trim().isEmpty) {
      return exercises;
    }

    final query = _query.toLowerCase();

    return exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(query) ||
          exercise.targetMuscle.toLowerCase().contains(query) ||
          exercise.equipment.toLowerCase().contains(query);
    }).toList();
  }

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

              ExerciseLoaded(:final exercises) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search exercise...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),

                      onChanged: (value) {
                        setState(() {
                          _query = value;
                        });
                      },
                    ),
                  ),

                  Expanded(
                    child: Builder(
                      builder: (_) {
                        final filtered = _filterExercises(exercises);

                        if (filtered.isEmpty) {
                          return const Center(child: Text('No exercise found'));
                        }

                        return ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (_, index) {
                            final exercise = filtered[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),

                              child: ListTile(
                                selected: _selectedExercises.contains(exercise),
                                title: Text(exercise.name),
                                subtitle: Text(
                                  '${exercise.targetMuscle} • '
                                  '${exercise.equipment}',
                                ),

                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                ),

                                onTap: () {
                                  setState(() {
                                    if (_selectedExercises.contains(exercise)) {
                                      _selectedExercises.remove(exercise);

                                      return;
                                    }

                                    if (_selectedExercises.length >=
                                        _maxSelection) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'You can select only $_maxSelection exercise(s)',
                                          ),
                                        ),
                                      );

                                      return;
                                    }

                                    _selectedExercises.add(exercise);
                                  });
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),

                    child: FilledButton(
                      onPressed: _selectedExercises.length != _maxSelection
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<ProgramExerciseCubit>(),
                                    child: ExerciseConfigurationPage(
                                      program: widget.program,
                                      draft: widget.draft,
                                      exercises: _selectedExercises,
                                    ),
                                  ),
                                ),
                              );
                            },

                      child: const Text('Configure'),
                    ),
                  ),
                ],
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
