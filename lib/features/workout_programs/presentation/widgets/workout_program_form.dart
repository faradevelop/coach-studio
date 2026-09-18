import 'dart:ui';

import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_dropdown.dart';
import 'package:coach_studio/core/widgets/app_number_picker.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
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
  late int _daysPerWeak;
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  ProgramGoal? _goal;
  ProgramLevel? _level;

  @override
  void initState() {
    super.initState();
    final program = widget.initialProgram;
    _titleController = TextEditingController(text: program?.title ?? '');
    _daysPerWeak = program?.daysPerWeek ?? 1;
    _notesController = TextEditingController(text: program?.notes ?? '');
    _goal = program?.goal;
    _level = program?.level;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final oldProgram = widget.initialProgram;

    final program = WorkoutProgram(
      id: oldProgram?.id ?? '',
      title: _titleController.text.trim(),
      goal: _goal!,
      level: _level!,
      daysPerWeek: _daysPerWeak,
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
              child: MaxWidthBox(
                maxWidth: AppContentWidth.form,
                child: Row(
                  children: [
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
            ),

            // Glass form card
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: MaxWidthBox(
                  maxWidth: AppContentWidth.form,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.charcoal.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: -2,
                        ),
                        BoxShadow(
                          color: AppColors.charcoal.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
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
                                  itemLabel: (goal) => goal.label,
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
                                  itemLabel: (level) => level.label,
                                  onChanged: widget.isLoading
                                      ? null
                                      : (value) {
                                          setState(() => _level = value);
                                        },
                                ),
                                const SizedBox(height: 20),

                                Visibility(
                                  visible: widget.initialProgram == null,
                                  child: AppNumberPicker(
                                    label: 'روز در هفته',
                                    value: _daysPerWeak,
                                    min: 1,
                                    max: 7,
                                    onChanged: (value) {
                                      _daysPerWeak = value;
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
