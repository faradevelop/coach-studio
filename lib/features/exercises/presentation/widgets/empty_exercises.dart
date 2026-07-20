import 'package:flutter/material.dart';

class EmptyExercises extends StatelessWidget {
  const EmptyExercises({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.fitness_center, size: 64),

          const SizedBox(height: 16),

          const Text(
            'No exercises yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            'Create your first exercise',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
