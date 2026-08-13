import 'dart:ui';

import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_selection_args.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_dropdown.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_draft.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/training_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateProgramExercisePage extends StatelessWidget {
  final WorkoutProgram program;

  const CreateProgramExercisePage({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return _CreateProgramExerciseView(program: program);
  }
}

class _CreateProgramExerciseView extends StatefulWidget {
  final WorkoutProgram program;

  const _CreateProgramExerciseView({required this.program});

  @override
  State<_CreateProgramExerciseView> createState() =>
      _CreateProgramExerciseViewState();
}

class _CreateProgramExerciseViewState
    extends State<_CreateProgramExerciseView> {
  int _day = 1;
  TrainingSystem _trainingSystem = TrainingSystem.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.orangeGlow,
              Color(0xFFFFC9A0),
              Color(0xFFFFF0E0),
              AppColors.cream,
            ],
            stops: [0.0, 0.18, 0.45, 1.0],
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
                        Text('تمرین جدید', style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: 130,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppDropdown<int>(
                              label: 'روز تمرین',
                              value: _day,
                              items: List.generate(
                                widget.program.daysPerWeek,
                                (index) => index + 1,
                              ),
                              itemLabel: (day) => 'روز $day',
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _day = value);
                              },
                            ),
                            const SizedBox(height: 20),

                            AppDropdown<TrainingSystem>(
                              label: 'سیستم تمرینی',
                              value: _trainingSystem,
                              items: TrainingSystem.values,
                              itemLabel: (system) => system.name,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _trainingSystem = value);
                              },
                            ),
                            const SizedBox(height: 36),

                            AppButton(
                              text: 'تایید و مرحله بعد',
                              onPressed: () {
                                final draft = ProgramExerciseDraft(
                                  programId: widget.program.id,
                                  day: _day,
                                  trainingSystem: _trainingSystem,
                                );

                                final args = ProgramExerciseSelectionArgs(
                                  program: widget.program,
                                  draft: draft,
                                );

                                context.pushReplacementNamed(
                                  AppRouteNames.addProgramExerciseItems,
                                  pathParameters: {
                                    'programId': widget.program.id,
                                  },
                                  extra: args,
                                );
                              },
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
        ),
      ),
    );
  }
}
