import 'package:flutter/material.dart';

class EmptyExercises extends StatelessWidget {
  const EmptyExercises({super.key});

  static const Color _charcoal = Color(0xFF2D2D2D);
  static const Color _orange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 32,
                color: _orange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No exercises added yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _charcoal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap Add to create the first one',
              style: TextStyle(fontSize: 13, color: _charcoal.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
