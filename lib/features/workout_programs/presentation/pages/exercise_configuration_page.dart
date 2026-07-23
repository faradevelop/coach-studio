import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_draft.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_item.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExerciseConfigurationPage extends StatelessWidget {
  final WorkoutProgram program;
  final ProgramExerciseDraft draft;
  final List<Exercise> exercises;

  const ExerciseConfigurationPage({
    super.key,
    required this.program,
    required this.draft,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return _ExerciseConfigurationView(
      program: program,
      draft: draft,
      exercises: exercises,
    );
  }
}

class _ExerciseConfigurationView extends StatefulWidget {
  final WorkoutProgram program;
  final ProgramExerciseDraft draft;
  final List<Exercise> exercises;

  const _ExerciseConfigurationView({
    required this.program,
    required this.draft,
    required this.exercises,
  });

  @override
  State<_ExerciseConfigurationView> createState() =>
      _ExerciseConfigurationViewState();
}

class _ExerciseConfigurationViewState
    extends State<_ExerciseConfigurationView> {
  final _setsController = TextEditingController();
  final _restController = TextEditingController();

  final Map<String, TextEditingController> _repsControllers = {};
  final Map<String, TextEditingController> _tempoControllers = {};

  @override
  void initState() {
    super.initState();

    _setsController.text = '4';
    _restController.text = '90';

    for (final exercise in widget.exercises) {
      _repsControllers[exercise.id] = TextEditingController(text: '10-12');

      _tempoControllers[exercise.id] = TextEditingController(text: '3-1-1');
    }
  }

  @override
  void dispose() {
    _setsController.dispose();
    _restController.dispose();

    for (final controller in _repsControllers.values) {
      controller.dispose();
    }

    for (final controller in _tempoControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _save() async {
    final items = widget.exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;

      return ProgramExerciseItem(
        id: '',
        programExerciseId: '',
        exerciseId: exercise.id,
        order: index + 1,
        reps: _repsControllers[exercise.id]!.text,
        tempo: _tempoControllers[exercise.id]!.text,
      );
    }).toList();

    final programExercise = ProgramExercise(
      id: '',
      programId: widget.program.id,
      day: widget.draft.day,
      order: 0,
      sets: _setsController.text,
      rest: _restController.text,
      trainingSystem: widget.draft.trainingSystem,
      items: items,
    );

    await context.read<ProgramExerciseCubit>().addProgramExercise(
      programExercise,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configure Program Exercise')),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          Text(
            widget.draft.trainingSystem.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: _setsController,
            decoration: const InputDecoration(labelText: 'Sets'),
          ),

          TextFormField(
            controller: _restController,
            decoration: const InputDecoration(labelText: 'Rest'),
          ),

          const SizedBox(height: 24),

          ...widget.exercises.map((exercise) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    TextFormField(
                      controller: _repsControllers[exercise.id],
                      decoration: const InputDecoration(labelText: 'Reps'),
                    ),

                    TextFormField(
                      controller: _tempoControllers[exercise.id],
                      decoration: const InputDecoration(labelText: 'Tempo'),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          FilledButton(
            onPressed: _save,

            child: const Text('Create Program Exercise'),
          ),
        ],
      ),
    );
  }
}
