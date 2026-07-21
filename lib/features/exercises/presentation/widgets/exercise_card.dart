import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:flutter/material.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Row(
          children: [
            _ExerciseImage(imageUrl: exercise.imageUrl ?? ''),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    exercise.targetMuscle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${exercise.equipment} • ${exercise.difficulty}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
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
          ],
        ),
      ),
    );
  }
}

class _ExerciseImage extends StatelessWidget {
  final String imageUrl;

  const _ExerciseImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),

        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),

      child: imageUrl.isEmpty
          ? const Icon(Icons.fitness_center, size: 32)
          : ClipRRect(
              borderRadius: BorderRadius.circular(12),

              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
    );
  }
}
