import 'package:flutter/material.dart';

class DeleteExerciseDialog extends StatelessWidget {
  const DeleteExerciseDialog({super.key, required this.exerciseName});

  final String exerciseName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Exercise'),

      content: Text('Are you sure you want to delete $exerciseName?'),

      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text('Cancel'),
        ),

        FilledButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
