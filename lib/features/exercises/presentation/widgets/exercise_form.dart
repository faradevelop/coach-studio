import 'dart:ui';
import 'package:coach_studio/core/constants/app_options.dart';
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

  // رنگ‌های مشترک با صفحه لیست
  static const Color _orange = Color(0xFFFF6B35);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _charcoal = Color(0xFF2D2D2D);

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
    final oldExercise = widget.initialExercise;
    final isEdit = oldExercise != null;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF9A5A), // نارنجی قوی بالا
            Color(0xFFFFC9A0),
            Color(0xFFFFF0E0),
            _cream,
          ],
          stops: [0.0, 0.18, 0.45, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // AppBar سفارشی
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
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _charcoal,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 3,
                        width: isEdit ? 92 : 88,
                        decoration: BoxDecoration(
                          color: _orange,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: _charcoal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // فرم داخل کارت شیشه‌ای
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.38),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.55),
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
                              onPressed: _submit,
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
