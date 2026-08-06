import 'dart:ui';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_draft.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_item.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ExerciseConfigurationPage extends StatelessWidget {
  final WorkoutProgram program;
  final ProgramExerciseDraft draft;
  final List<Exercise> exercises;
  final ProgramExercise? existingExercise;

  const ExerciseConfigurationPage({
    super.key,
    required this.program,
    required this.draft,
    required this.exercises,
    this.existingExercise,
  });

  @override
  Widget build(BuildContext context) {
    return _ExerciseConfigurationView(
      program: program,
      draft: draft,
      exercises: exercises,
      existingExercise: existingExercise,
    );
  }
}

class _ExerciseConfigurationView extends StatefulWidget {
  final WorkoutProgram program;
  final ProgramExerciseDraft draft;
  final List<Exercise> exercises;
  final ProgramExercise? existingExercise;

  const _ExerciseConfigurationView({
    required this.program,
    required this.draft,
    required this.exercises,
    this.existingExercise,
  });

  @override
  State<_ExerciseConfigurationView> createState() =>
      _ExerciseConfigurationViewState();
}

class _ExerciseConfigurationViewState
    extends State<_ExerciseConfigurationView> {
  final _setsController = TextEditingController();
  final _restController = TextEditingController();

  final Map<String, TextEditingController> _repsControllers = {};
  final Map<String, TextEditingController> _tempoControllers = {};
  final Map<String, TextEditingController> _descriptionControllers = {};

  static const Color _orange = Color(0xFFFF6B35);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _charcoal = Color(0xFF2D2D2D);

  bool get _isEditMode => widget.existingExercise != null;

  ProgramExerciseItem? _existingItemFor(String exerciseId) {
    final items = widget.existingExercise?.items;
    if (items == null) return null;

    for (final item in items) {
      if (item.exerciseId == exerciseId) return item;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    final existing = widget.existingExercise;

    _setsController.text = existing?.sets ?? '4';
    _restController.text = existing?.rest ?? '90';

    for (final exercise in widget.exercises) {
      final existingItem = _existingItemFor(exercise.id);

      _repsControllers[exercise.id] = TextEditingController(
        text: existingItem?.reps ?? '10-12',
      );

      _tempoControllers[exercise.id] = TextEditingController(
        text: existingItem?.tempo ?? '3-1-1',
      );

      _descriptionControllers[exercise.id] = TextEditingController(
        text: existingItem?.description ?? '',
      );
    }
  }

  @override
  void dispose() {
    _setsController.dispose();
    _restController.dispose();

    for (final controller in _repsControllers.values) {
      controller.dispose();
    }
    for (final controller in _tempoControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _save() async {
    final existing = widget.existingExercise;

    final items = widget.exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;
      final existingItem = _existingItemFor(exercise.id);

      return ProgramExerciseItem(
        id: existingItem?.id ?? '',
        programExerciseId: existing?.id ?? '',
        exerciseId: exercise.id,
        order: index + 1,
        reps: _repsControllers[exercise.id]!.text,
        tempo: _tempoControllers[exercise.id]!.text,
        description: _descriptionControllers[exercise.id]!.text.isEmpty
            ? ''
            : _descriptionControllers[exercise.id]!.text,
      );
    }).toList();

    final programExercise = ProgramExercise(
      id: existing?.id ?? '',
      workoutId: widget.program.id,
      day: widget.draft.day,
      order: existing?.order ?? 0,
      sets: _setsController.text,
      rest: _restController.text,
      trainingSystem: widget.draft.trainingSystem,
      items: items,
    );

    final cubit = context.read<ProgramExerciseCubit>();

    if (_isEditMode) {
      await cubit.updateProgramExercise(programExercise);
    } else {
      await cubit.addProgramExercise(programExercise);
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      body: Container(
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
              // AppBar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    const SizedBox(width: 40),

                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          _isEditMode ? 'ویرایش تمرین' : 'تنظیم تمرین',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _charcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: _isEditMode ? 90 : 120,
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
                          color: Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
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

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    children: [
                      // کارت اطلاعات کلی
                      _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _orange.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.draft.trainingSystem.name,
                                    style: const TextStyle(
                                      color: _orange,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'روز ${widget.draft.day}',
                                  style: TextStyle(
                                    color: _charcoal.withValues(alpha: 0.7),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            AppTextField(
                              controller: _setsController,
                              label: 'ست',
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _restController,
                              label: 'استراحت',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // کارت‌های هر تمرین
                      ...widget.exercises.map((exercise) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _GlassCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exercise.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _charcoal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${exercise.targetMuscle} • ${exercise.equipment}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: _charcoal.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: _repsControllers[exercise.id]!,
                                  label: 'تکرار',
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller: _tempoControllers[exercise.id]!,
                                  label: 'تمپو',
                                ),
                                const SizedBox(height: 14),
                                AppTextField(
                                  controller:
                                      _descriptionControllers[exercise.id]!,
                                  label: 'توضیح',
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 12),

                      AppButton(
                        text: _isEditMode ? 'ویرایش' : 'تایید',
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.38),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.55),
              width: 1.1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
