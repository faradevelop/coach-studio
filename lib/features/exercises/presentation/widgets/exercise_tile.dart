import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:flutter/material.dart';

class ExerciseTile extends StatelessWidget {
  final ExerciseModel exercise;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExerciseTile({
    super.key,
    required this.exercise,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: ListTile(
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.targetMuscle),

            const SizedBox(height: 4),

            Text('${exercise.difficulty} • ${exercise.equipment}'),
          ],
        ),

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();

              case 'delete':
                onDelete?.call();
            }
          },

          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),

            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
