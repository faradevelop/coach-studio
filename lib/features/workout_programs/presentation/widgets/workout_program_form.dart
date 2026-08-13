import 'dart:ui';

import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_dropdown.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkoutProgramForm extends StatefulWidget {
  final WorkoutProgram? initialProgram;
  final bool isLoading;
  final Function(WorkoutProgram program) onSubmit;

  const WorkoutProgramForm({
    super.key,
    this.initialProgram,
    this.isLoading = false,
    required this.onSubmit,
  });

  @override
  State<WorkoutProgramForm> createState() => _WorkoutProgramFormState();
}

class _WorkoutProgramFormState extends State<WorkoutProgramForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _daysController;
  late final TextEditingController _notesController;
  ProgramGoal? _goal;
  ProgramLevel? _level;

  @override
  void initState() {
    super.initState();
    final program = widget.initialProgram;
    _titleController = TextEditingController(text: program?.title ?? '');
    _daysController = TextEditingController(
      text: program?.daysPerWeek.toString() ?? '',
    );
    _notesController = TextEditingController(text: program?.notes ?? '');
    _goal = program?.goal;
    _level = program?.level;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _daysController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _goalLabel(ProgramGoal goal) {
    return switch (goal) {
      ProgramGoal.hypertrophy => 'هایپرتروفی',
      ProgramGoal.strength => 'قدرتی',
      ProgramGoal.fatLoss => 'چربی‌سوزی',
      ProgramGoal.endurance => 'استقامتی',
      ProgramGoal.rehabilitation => 'توان‌بخشی',
    };
  }

  String _levelLabel(ProgramLevel level) {
    return switch (level) {
      ProgramLevel.beginner => 'مبتدی',
      ProgramLevel.intermediate => 'متوسط',
      ProgramLevel.advanced => 'پیشرفته',
    };
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final oldProgram = widget.initialProgram;

    final program = WorkoutProgram(
      id: oldProgram?.id ?? '',
      title: _titleController.text.trim(),
      goal: _goal!,
      level: _level!,
      daysPerWeek: int.parse(_daysController.text),
      notes: _notesController.text.trim(),
      isTemplate: oldProgram?.isTemplate ?? true,
    );

    widget.onSubmit(program);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialProgram != null;

    return Container(
      decoration: const BoxDecoration(
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
                        isEdit ? 'ویرایش برنامه' : 'ایجاد برنامه',
                        style: AppTextStyles.title,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 3,
                        width: isEdit ? 92 : 110,
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
                          color: AppColors.glassBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppTextField(
                              controller: _titleController,
                              label: 'نام برنامه',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            AppDropdown<ProgramGoal>(
                              label: 'هدف',
                              value: _goal,
                              items: ProgramGoal.values,
                              itemLabel: _goalLabel,
                              onChanged: widget.isLoading
                                  ? null
                                  : (value) {
                                      setState(() => _goal = value);
                                    },
                            ),
                            const SizedBox(height: 20),

                            AppDropdown<ProgramLevel>(
                              label: 'سطح',
                              value: _level,
                              items: ProgramLevel.values,
                              itemLabel: _levelLabel,
                              onChanged: widget.isLoading
                                  ? null
                                  : (value) {
                                      setState(() => _level = value);
                                    },
                            ),
                            const SizedBox(height: 20),

                            Visibility(
                              visible: widget.initialProgram == null,
                              child: AppTextField(
                                controller: _daysController,
                                label: 'روز در هفته',
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Enter number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),

                            AppTextField(
                              controller: _notesController,
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
