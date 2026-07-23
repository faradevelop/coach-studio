import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_draft.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/pages/add_program_exercise_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateProgramExercisePage extends StatelessWidget {
  final WorkoutProgram program;

  const CreateProgramExercisePage({super.key, required this.program});

  @override
  Widget build(Object context) {
    return BlocProvider(
      create: (_) => sl<ProgramExerciseCubit>(),
      child: _CreateProgramExerciseView(program: program),
    );
  }

  // @override
  // State<CreateProgramExercisePage> createState() =>
  //     _CreateProgramExercisePageState();
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

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<ProgramExerciseCubit>(),
                      child: AddProgramExercisePage(
                        program: widget.program,
                        draft: draft,
                      ),
                    ),
                  ),
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
