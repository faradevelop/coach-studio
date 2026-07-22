import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExerciseConfigurationPage extends StatelessWidget {
  final WorkoutProgram program;
  final Exercise exercise;
  final ProgramExercise? existingExercise;

  const ExerciseConfigurationPage({
    super.key,
    required this.program,
    required this.exercise,
    this.existingExercise,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProgramExerciseCubit>(),
      child: _ExerciseConfigurationView(
        program: program,
        exercise: exercise,
        existingExercise: existingExercise,
      ),
    );
  }
}

class _ExerciseConfigurationView extends StatefulWidget {
  final WorkoutProgram program;
  final Exercise exercise;
  final ProgramExercise? existingExercise;

  const _ExerciseConfigurationView({
    required this.program,
    required this.exercise,
    this.existingExercise,
  });

  @override
  State<_ExerciseConfigurationView> createState() =>
      _ExerciseConfigurationViewState();
}

class _ExerciseConfigurationViewState
    extends State<_ExerciseConfigurationView> {
  final _formKey = GlobalKey<FormState>();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _tempoController = TextEditingController();
  final _restController = TextEditingController();

  TrainingSystem _trainingSystem = TrainingSystem.superSet;
  int _day = 1;

  @override
  void initState() {
    super.initState();

    final existing = widget.existingExercise;

    if (existing != null) {
      _setsController.text = existing.sets;
      _repsController.text = existing.reps;
      _tempoController.text = existing.tempo;
      _restController.text = existing.rest;

      _trainingSystem = existing.trainingSystem;
      _day = existing.day;
    } else {
      _setsController.text = '4';
      _repsController.text = '10-12';
      _tempoController.text = '3-1-1';
      _restController.text = '90';
    }
  }

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
    return Scaffold(
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

              DropdownButtonFormField<int>(
                initialValue: _day,
                decoration: const InputDecoration(labelText: 'Training Day'),
                items: List.generate(widget.program.daysPerWeek, (index) {
                  final day = index + 1;
                  return DropdownMenuItem(value: day, child: Text('Day $day'));
                }),

                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _day = value;
                  });
                },
              ),

              DropdownButtonFormField<TrainingSystem>(
                initialValue: _trainingSystem,
                decoration: const InputDecoration(labelText: 'Training System'),

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
                    id: widget.existingExercise?.id ?? '',
                    programId: widget.program.id,
                    exerciseId: widget.exercise.id,
                    day: _day,
                    order: 0, // This will be set in the repository
                    sets: _setsController.text,
                    reps: _repsController.text,
                    tempo: _tempoController.text,
                    rest: _restController.text,
                    trainingSystem: _trainingSystem,
                  );

                  final cubit = context.read<ProgramExerciseCubit>();

                  if (widget.existingExercise == null) {
                    await cubit.addProgramExercise(programExercise);
                  } else {
                    await cubit.updateProgramExercise(programExercise);
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },

                child: Text(
                  widget.existingExercise == null
                      ? 'Save Exercise'
                      : 'Update Exercise',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
