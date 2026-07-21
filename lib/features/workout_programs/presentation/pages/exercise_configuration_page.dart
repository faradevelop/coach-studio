import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExerciseConfigurationPage extends StatefulWidget {
  final WorkoutProgram program;
  final Exercise exercise;

  const ExerciseConfigurationPage({
    super.key,
    required this.exercise,
    required this.program,
  });

  @override
  State<ExerciseConfigurationPage> createState() =>
      _ExerciseConfigurationPageState();
}

class _ExerciseConfigurationPageState extends State<ExerciseConfigurationPage> {
  final _formKey = GlobalKey<FormState>();
  final _setsController = TextEditingController(text: '4');
  final _repsController = TextEditingController(text: '10-12');
  final _tempoController = TextEditingController(text: '3-1-1');
  final _restController = TextEditingController(text: '90');

  TrainingSystem _trainingSystem = TrainingSystem.dropSet;

  int _day = 1;
  int _order = 1;

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _tempoController.dispose();
    _restController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProgramExerciseCubit>(),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.exercise.name)),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  widget.exercise.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _setsController,
                  decoration: const InputDecoration(labelText: 'Sets'),
                ),
                TextFormField(
                  controller: _repsController,
                  decoration: const InputDecoration(labelText: 'Reps'),
                ),
                TextFormField(
                  controller: _tempoController,
                  decoration: const InputDecoration(labelText: 'Tempo'),
                ),

                TextFormField(
                  controller: _restController,
                  decoration: const InputDecoration(labelText: 'Rest'),
                ),

                DropdownButtonFormField<TrainingSystem>(
                  initialValue: _trainingSystem,
                  decoration: const InputDecoration(
                    labelText: 'Training System',
                  ),
                  items: TrainingSystem.values.map((system) {
                    return DropdownMenuItem(
                      value: system,
                      child: Text(system.name),
                    );
                  }).toList(),

                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _trainingSystem = value;
                    });
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () async {
                    final programExercise = ProgramExercise(
                      id: '',
                      programId: widget.program.id,
                      exerciseId: widget.exercise.id,
                      day: _day,
                      order: _order,
                      sets: _setsController.text,
                      reps: _repsController.text,
                      tempo: _tempoController.text,
                      rest: _restController.text,
                      trainingSystem: _trainingSystem,
                    );

                    await context
                        .read<ProgramExerciseCubit>()
                        .addProgramExercise(programExercise);

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },

                  child: const Text('Save Exercise'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
