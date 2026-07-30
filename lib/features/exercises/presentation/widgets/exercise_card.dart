import 'dart:ui';

import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: 50,
      height: 105,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 233, 222, 212),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            _ExerciseImage(imageUrl: exercise.imageUrl ?? ''),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Spacer(),

                        MiniButton(
                          color: Colors.blueAccent.withOpacity(0.38),
                          icon: Icon(
                            Icons.edit,
                            size: 14,
                            color: const Color.fromARGB(255, 3, 29, 157),
                          ),
                          onPressed: onEdit,
                        ),
                        SizedBox(width: 6),
                        MiniButton(
                          color: Colors.red.withOpacity(0.38),
                          icon: FaIcon(
                            FontAwesomeIcons.trash,
                            size: 12,
                            color: const Color.fromARGB(255, 186, 10, 10),
                          ),
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.fireFlameCurved,
                        size: 14,
                        color: const Color.fromARGB(255, 186, 10, 10),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        exercise.targetMuscle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // FaIcon(
                      //   FontAwesomeIcons.dumbbell,
                      //   size: 14,
                      //   color: const Color.fromARGB(255, 27, 5, 195),
                      // ),
                      // const SizedBox(width: 4),
                      // Text(
                      //   exercise.equipment,
                      //   style: Theme.of(context).textTheme.bodySmall,
                      // ),
                      // const SizedBox(width: 6),
                      Icon(
                        CupertinoIcons.chart_bar_fill,
                        size: 14,
                        color: const Color.fromARGB(255, 84, 53, 237),
                      ),

                      const SizedBox(width: 4),
                      Text(
                        exercise.difficulty,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // PopupMenuButton<String>(
            //   onSelected: (value) {
            //     switch (value) {
            //       case 'edit':
            //         onEdit?.call();

            //       case 'delete':
            //         onDelete?.call();
            //     }
            //   },

            //   itemBuilder: (_) => const [
            //     PopupMenuItem(value: 'edit', child: Text('Edit')),

            //     PopupMenuItem(value: 'delete', child: Text('Delete')),
            //   ],
            // ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.38),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1.2,
            ),
          ),
          child: imageUrl.isEmpty
              ? const Icon(Icons.fitness_center_rounded, size: 32)
              : ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }
}
