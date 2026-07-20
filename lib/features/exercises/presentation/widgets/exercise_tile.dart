import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:flutter/material.dart';

class ExerciseTile extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseTile({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(exercise.name),
      subtitle: Text(exercise.targetMuscle),
    );
  }
}
