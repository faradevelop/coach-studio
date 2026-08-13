import 'dart:ui';

import 'package:coach_studio/core/constants/app_options.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_dropdown.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExerciseForm extends StatefulWidget {
  final Exercise? initialExercise;
  final bool isLoading;
  final Function(Exercise exercise) onSubmit;

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
    if (!_formKey.currentState!.validate()) return;

    final oldExercise = widget.initialExercise;

    final exercise = Exercise(
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
    final isEdit = widget.initialExercise != null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.bgColors,
          stops: AppColors.bgStops,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        isEdit ? 'ویرایش تمرین' : 'ایجاد تمرین',
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 3,
                        width: isEdit ? 92 : 88,
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GlassyBackButton(onTap: () => context.pop()),
                ],
              ),
            ),

            // Glass form card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.38),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.55),
                          width: 1.2,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              controller: _nameController,
                              label: 'نام تمرین',
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            AppDropdown<String>(
                              label: 'عضله هدف',
                              value: _selectedMuscle,
                              items: AppOptions.muscles,
                              itemLabel: (item) => item,
                              onChanged: (value) {
                                setState(() => _selectedMuscle = value);
                              },
                            ),
                            const SizedBox(height: 20),
                            AppDropdown<String>(
                              label: 'سطح',
                              value: _selectedDifficulty,
                              items: AppOptions.difficulties,
                              itemLabel: (item) => item,
                              onChanged: (value) {
                                setState(() => _selectedDifficulty = value);
                              },
                            ),
                            const SizedBox(height: 20),
                            AppDropdown<String>(
                              label: 'وسیله',
                              value: _selectedEquipment,
                              items: AppOptions.equipments,
                              itemLabel: (item) => item,
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
            ),
          ],
        ),
      ),
    );
  }
}
