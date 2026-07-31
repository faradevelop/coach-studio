import 'dart:ui';
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

  static const Color _orange = Color(0xFFFF6B35);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _charcoal = Color(0xFF2D2D2D);

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
          colors: [
            Color(0xFFFF9A5A),
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
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: _charcoal,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        isEdit ? 'Edit Program' : 'Create Program',
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
                        width: isEdit ? 92 : 110,
                        decoration: BoxDecoration(
                          color: _orange,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
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
                              controller: _titleController,
                              label: 'Program Name',
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            AppDropdown<ProgramGoal>(
                              label: 'Goal',
                              value: _goal,
                              items: ProgramGoal.values,
                              itemLabel: (item) => item.name,
                              onChanged: widget.isLoading
                                  ? null
                                  : (value) {
                                      setState(() => _goal = value);
                                    },
                            ),
                            const SizedBox(height: 20),

                            AppDropdown<ProgramLevel>(
                              label: 'Level',
                              value: _level,
                              items: ProgramLevel.values,
                              itemLabel: (item) => item.name,
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
                                label: 'Days Per Week',
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
                              label: 'Notes',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 32),

                            AppButton(
                              text: isEdit ? 'Update' : 'Create',
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
