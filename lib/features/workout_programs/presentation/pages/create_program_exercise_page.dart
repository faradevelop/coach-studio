import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_selection_args.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_draft.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateProgramExercisePage extends StatelessWidget {
  final WorkoutProgram program;

  const CreateProgramExercisePage({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return _CreateProgramExerciseView(program: program);
  }
}

class _CreateProgramExerciseView extends StatefulWidget {
  final WorkoutProgram program;
  const _CreateProgramExerciseView({required this.program});

  @override
  State<StatefulWidget> createState() => _CreateProgramExerciseViewState();
}

class _CreateProgramExerciseViewState
    extends State<_CreateProgramExerciseView> {
  int _day = 1;
  TrainingSystem _trainingSystem = TrainingSystem.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Exercise Block')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
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

            const SizedBox(height: 16),

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

            const Spacer(),

            FilledButton(
              onPressed: () {
                final draft = ProgramExerciseDraft(
                  programId: widget.program.id,
                  day: _day,
                  trainingSystem: _trainingSystem,
                );

                final args = ProgramExerciseSelectionArgs(
                  program: widget.program,
                  draft: draft,
                );

                context.pushReplacementNamed(
                  AppRouteNames.addProgramExerciseItems,
                  pathParameters: {'programId': widget.program.id},
                  extra: args,
                );
              },

              child: const Text('Select Exercises'),
            ),
          ],
        ),
      ),
    );
  }
}
