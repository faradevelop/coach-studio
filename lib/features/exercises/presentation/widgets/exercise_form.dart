import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/features/exercises/data/models/exercise_model.dart';
import 'package:flutter/material.dart';

class ExerciseForm extends StatefulWidget {
  final ExerciseModel? initialExercise;
  final bool isLoading;

  final Function(ExerciseModel exercise) onSubmit;

  const ExerciseForm({
    super.key,
    this.initialExercise,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _muscleController;
  late final TextEditingController _difficultyController;
  late final TextEditingController _equipmentController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    final exercise = widget.initialExercise;

    _nameController = TextEditingController(text: exercise?.name ?? '');

    _muscleController = TextEditingController(
      text: exercise?.targetMuscle ?? '',
    );

    _difficultyController = TextEditingController(
      text: exercise?.difficulty ?? '',
    );

    _equipmentController = TextEditingController(
      text: exercise?.equipment ?? '',
    );

    _descriptionController = TextEditingController(
      text: exercise?.description ?? '',
    );
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

    final oldExercise = widget.initialExercise;

    final exercise = ExerciseModel(
      id: oldExercise?.id ?? '',

      name: _nameController.text.trim(),

      targetMuscle: _muscleController.text.trim(),

      difficulty: _difficultyController.text.trim(),

      equipment: _equipmentController.text.trim(),

      imageUrl: oldExercise?.imageUrl ?? '',

      videoUrl: oldExercise?.videoUrl ?? '',

      description: _descriptionController.text.trim(),

      isActive: oldExercise?.isActive ?? true,
    );

    widget.onSubmit(exercise);
  }

  @override
  Widget build(BuildContext context) {
    final oldExercise = widget.initialExercise;

    return Form(
      key: _formKey,

      child: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          AppTextField(
            controller: _nameController,
            label: 'Name',
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
          ),
          AppTextField(controller: _muscleController, label: 'Target Muscle'),
          AppTextField(controller: _difficultyController, label: 'Difficulty'),
          AppTextField(controller: _equipmentController, label: 'Equipment'),
          AppTextField(
            controller: _descriptionController,
            label: 'Description',
            maxLines: 3,
          ),

          const SizedBox(height: 28),

          AppButton(
            text: oldExercise == null ? 'Create' : 'Update',
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
