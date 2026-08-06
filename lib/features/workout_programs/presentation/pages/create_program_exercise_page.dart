import 'dart:ui';
import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_selection_args.dart';
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
  State<StatefulWidget> createState() => _CreateProgramExerciseViewState();
}

class _CreateProgramExerciseViewState
    extends State<_CreateProgramExerciseView> {
  int _day = 1;
  TrainingSystem _trainingSystem = TrainingSystem.normal;

  static const Color _orange = Color(0xFFFF6B35);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _charcoal = Color(0xFF2D2D2D);

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
              // AppBar سفارشی
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    const SizedBox(width: 40),

                    const Spacer(),
                    Column(
                      children: [
                        const Text(
                          'تمرین جدید',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _charcoal,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: 130,
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

              // محتوا
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
                          color: Colors.white.withValues(alpha: 0.38),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.55),
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Day Dropdown
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

                            // Training System Dropdown
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

                            // دکمه ادامه
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
