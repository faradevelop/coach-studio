import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditExercisePage extends StatefulWidget {
  final ExerciseModel exercise;

  const EditExercisePage({super.key, required this.exercise});

  @override
  State<EditExercisePage> createState() => _EditExercisePageState();
}

class _EditExercisePageState extends State<EditExercisePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _muscleController;
  late final TextEditingController _difficultyController;
  late final TextEditingController _equipmentController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    final exercise = widget.exercise;

    _nameController = TextEditingController(text: exercise.name);

    _muscleController = TextEditingController(text: exercise.targetMuscle);

    _difficultyController = TextEditingController(text: exercise.difficulty);

    _equipmentController = TextEditingController(text: exercise.equipment);

    _descriptionController = TextEditingController(text: exercise.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _muscleController.dispose();
    _difficultyController.dispose();
    _equipmentController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedExercise = widget.exercise.copyWith(
      name: _nameController.text.trim(),
      targetMuscle: _muscleController.text.trim(),
      difficulty: _difficultyController.text.trim(),
      equipment: _equipmentController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    context.read<ExerciseCubit>().updateExercise(updatedExercise);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Exercise')),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),

              TextFormField(
                controller: _muscleController,
                decoration: const InputDecoration(labelText: 'Target Muscle'),
              ),

              TextFormField(
                controller: _difficultyController,
                decoration: const InputDecoration(labelText: 'Difficulty'),
              ),

              TextFormField(
                controller: _equipmentController,
                decoration: const InputDecoration(labelText: 'Equipment'),
              ),

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),

                maxLines: 3,
              ),

              const SizedBox(height: 24),

              FilledButton(onPressed: _submit, child: const Text('Update')),
            ],
          ),
        ),
      ),
    );
  }
}
