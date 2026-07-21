import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:flutter/material.dart';

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

            Text('Days per week: ${program.daysPerWeek}'),

            if (program.notes != null && program.notes!.isNotEmpty)
              Text('Notes: ${program.notes}'),

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
                    // later
                  },

                  icon: const Icon(Icons.add),

                  label: const Text('Add Exercise'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Expanded(
              child: Center(child: Text('No exercises added yet')),
            ),
          ],
        ),
      ),
    );
  }
}
