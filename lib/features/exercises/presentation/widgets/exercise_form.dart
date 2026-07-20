import 'package:coach_studio/core/constants/app_options.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_dropdown.dart';
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
  late final TextEditingController _descriptionController;
  String? _selectedMuscle;
  String? _selectedDifficulty;
  String? _selectedEquipment;

  @override
  void initState() {
    super.initState();

    final exercise = widget.initialExercise;

    _nameController = TextEditingController(text: exercise?.name ?? '');
    _selectedMuscle = exercise?.targetMuscle;
    _selectedDifficulty = exercise?.difficulty;
    _selectedEquipment = exercise?.equipment;
    _descriptionController = TextEditingController(
      text: exercise?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      targetMuscle: _selectedMuscle ?? '',
      difficulty: _selectedDifficulty ?? '',
      equipment: _selectedEquipment ?? '',
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
          const SizedBox(height: 22),
          AppDropdown<String>(
            label: 'Target Muscle',
            value: _selectedMuscle,
            items: AppOptions.muscles,
            itemLabel: (item) => item,
            onChanged: (value) {
              setState(() {
                _selectedMuscle = value;
              });
            },
          ),
          const SizedBox(height: 22),
          AppDropdown<String>(
            label: 'Difficulty',
            value: _selectedDifficulty,
            items: AppOptions.difficulties,
            itemLabel: (item) => item,
            onChanged: (value) {
              setState(() {
                _selectedDifficulty = value;
              });
            },
          ),
          const SizedBox(height: 22),
          AppDropdown<String>(
            label: 'Equipment',
            value: _selectedEquipment,
            items: AppOptions.equipments,
            itemLabel: (item) => item,
            onChanged: (value) {
              setState(() {
                _selectedEquipment = value;
              });
            },
          ),
          const SizedBox(height: 22),
          AppTextField(
            controller: _descriptionController,
            label: 'Description',
            maxLines: 3,
          ),
          const SizedBox(height: 32),
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
