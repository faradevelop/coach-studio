import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key});

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _muscleController = TextEditingController();
  final _difficultyController = TextEditingController();
  final _equipmentController = TextEditingController();
  final _descriptionController = TextEditingController();

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

    final exercise = ExerciseModel(
      id: '',
      name: _nameController.text.trim(),
      targetMuscle: _muscleController.text.trim(),
      difficulty: _difficultyController.text.trim(),
      equipment: _equipmentController.text.trim(),
      imageUrl: '',
      videoUrl: '',
      description: _descriptionController.text.trim(),
      isActive: true,
    );

    context.read<ExerciseCubit>().addExercise(exercise);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Exercise')),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
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

              FilledButton(onPressed: _submit, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
