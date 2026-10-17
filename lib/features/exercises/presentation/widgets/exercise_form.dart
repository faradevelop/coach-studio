import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_dropdown.dart';
import 'package:coach_studio/core/widgets/app_surface.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/core/widgets/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';
import 'package:coach_studio/features/exercises/domain/enums/difficulty.dart';
import 'package:coach_studio/features/exercises/domain/enums/equipment.dart';
import 'package:coach_studio/features/exercises/domain/enums/exercise_type.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/muscle_selector_field.dart';
import 'package:flutter/material.dart';

/// Page background is provided by the hosting Scaffold
/// (see AddExercisePage / EditExercisePage).
class ExerciseForm extends StatefulWidget {
  final List<Muscle> muscles;
  final Exercise? initialExercise;
  final bool isLoading;
  final Function(Exercise exercise) onSubmit;

  const ExerciseForm({
    super.key,
    required this.muscles,
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
  ExerciseType? _selectedType;
  List<Muscle> _selectedMuscles = [];
  Difficulty? _selectedDifficulty;
  Equipment? _selectedEquipment;

  String? _musclesError;

  @override
  void initState() {
    super.initState();

    final exercise = widget.initialExercise;

    _nameController = TextEditingController(text: exercise?.name ?? '');
    _selectedType = exercise?.type;
    _selectedMuscles = List<Muscle>.from(exercise?.targetMuscles ?? const []);
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
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMuscles.isEmpty) {
      setState(() => _musclesError = 'حداقل یک عضله را انتخاب کنید');
      return;
    }

    final oldExercise = widget.initialExercise;

    final type = _selectedType;
    if (type == null) return; // unreachable after validate(); avoids '!'
    final exercise = Exercise(
      id: oldExercise?.id ?? '',
      name: _nameController.text.trim(),
      type: type,
      targetMuscles: _selectedMuscles,
      difficulty: _selectedDifficulty ?? Difficulty.values.first,
      equipment: _selectedEquipment ?? Equipment.values.first,
      imageUrl: oldExercise?.imageUrl ?? '',
      videoUrl: oldExercise?.videoUrl ?? '',
      description: _descriptionController.text.trim(),
      instructions: oldExercise?.instructions,
      mistakes: oldExercise?.mistakes,
      isActive: oldExercise?.isActive ?? true,
    );

    widget.onSubmit(exercise);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialExercise != null;

    return SafeArea(
      child: Column(
        children: [
          MaxWidthBox(
            maxWidth: AppContentWidth.form,
            child: InnerPagesAppBar(
              rightButton: const SizedBox(width: 40),
              title: isEdit ? 'ویرایش تمرین' : 'ایجاد تمرین',
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: MaxWidthBox(
                maxWidth: AppContentWidth.form,
                child: AppSurface(
                  padding: const EdgeInsets.all(22),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _nameController,
                          label: 'نام تمرین',
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppDropdown<ExerciseType>(
                              label: 'نوع تمرین',
                              value: _selectedType,
                              items: ExerciseType.values,
                              itemLabel: (item) => item.label,
                              validator: (v) => v == null ? 'الزامی' : null,
                              onChanged: (value) =>
                                  setState(() => _selectedType = value),
                            ),
                            const SizedBox(height: 20),
                            MuscleSelectorField(
                              allMuscles: widget.muscles,
                              selected: _selectedMuscles,
                              errorText: _musclesError,
                              onChanged: (muscles) {
                                setState(() {
                                  _selectedMuscles = muscles;
                                  _musclesError = null;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppDropdown<Difficulty>(
                          label: 'سطح',
                          value: _selectedDifficulty,
                          items: Difficulty.values,
                          itemLabel: (item) => item.label,
                          onChanged: (value) {
                            setState(() => _selectedDifficulty = value);
                          },
                        ),
                        const SizedBox(height: 20),
                        AppDropdown<Equipment>(
                          label: 'وسیله',
                          value: _selectedEquipment,
                          items: Equipment.values,
                          itemLabel: (item) => item.label,
                          onChanged: (value) {
                            setState(() => _selectedEquipment = value);
                          },
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: _descriptionController,
                          label: 'توضیح',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        AppButton(
                          text: isEdit ? 'ویرایش' : 'تایید',
                          isLoading: widget.isLoading,
                          onPressed: widget.isLoading ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
