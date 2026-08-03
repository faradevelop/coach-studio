import 'dart:ui';
import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_configuration_args.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/delete_dialog.dart';
import 'package:coach_studio/features/workout_programs/data/services/workout_program_pdf_generator.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/athlete_info.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_draft.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program_details.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/athlete_info_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

class WorkoutProgramDetailPage extends StatelessWidget {
  final WorkoutProgram program;

  const WorkoutProgramDetailPage({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    context.read<ProgramExerciseCubit>().loadExercises(program.id);
    return _WorkoutProgramDetailView(program: program);
  }
}

class _WorkoutProgramDetailView extends StatelessWidget {
  final WorkoutProgram program;
  const _WorkoutProgramDetailView({required this.program});

  static const Color _orange = Color(0xFFFF6B35);
  static const Color _cream = Color(0xFFFFF8F0);
  static const Color _charcoal = Color(0xFF2D2D2D);

  Map<int, List<ProgramExerciseDetails>> _groupByDay(
    List<ProgramExerciseDetails> exercises,
  ) {
    final map = <int, List<ProgramExerciseDetails>>{};

    for (final exercise in exercises) {
      map.putIfAbsent(exercise.programExercise.day, () => []);
      map[exercise.programExercise.day]!.add(exercise);
    }

    for (final list in map.values) {
      list.sort(
        (a, b) => a.programExercise.order.compareTo(b.programExercise.order),
      );
    }

    return map;
  }

  Future<void> _generatePdf(BuildContext context) async {
    final state = context.read<ProgramExerciseCubit>().state;

    if (state is! ProgramExerciseLoaded || state.exercises.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ابتدا تمرین اضافه کنید')));
      return;
    }

    final athlete = await showDialog<AthleteInfo>(
      context: context,
      builder: (_) => const AthleteInfoFormDialog(),
    );
    if (athlete == null || !context.mounted) return;

    final details = WorkoutProgramDetails(
      program: program,
      exercises: state.exercises,
    );

    final bytes = await WorkoutProgramPdfGenerator().generate(
      details: details,
      athlete: athlete,
    );

    await Printing.sharePdf(bytes: bytes, filename: '${program.title}.pdf');
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
                    GestureDetector(
                      onTap: () => _generatePdf(context),
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
                          Icons.picture_as_pdf_rounded,
                          size: 22,
                          color: _charcoal,
                        ),
                      ),
                    ),

                    const Spacer(),
                    Column(
                      children: [
                        Text(
                          program.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _charcoal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 3,
                          width: 60,
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

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // کارت اطلاعات برنامه
                      _GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  program.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _charcoal,
                                  ),
                                ),
                                Spacer(),
                                MiniButton(
                                  color: Colors.blueAccent.withOpacity(0.38),
                                  icon: Icon(
                                    Icons.edit,
                                    size: 14,
                                    color: const Color.fromARGB(
                                      255,
                                      3,
                                      29,
                                      157,
                                    ),
                                  ),
                                  onPressed: () {
                                    context.pushNamed(
                                      AppRouteNames.createWorkoutProgram,
                                      extra: program,
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _InfoChip(
                                  icon: Icons.flag_rounded,
                                  text: program.goal.name,
                                ),
                                _InfoChip(
                                  icon: Icons.bar_chart_rounded,
                                  text: program.level.name,
                                ),
                                _InfoChip(
                                  icon: Icons.calendar_today_rounded,
                                  text: '${program.daysPerWeek} روز در هفته',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // هدر Exercises + دکمه افزودن
                      Row(
                        children: [
                          const Text(
                            'تمرین‌ها',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _charcoal,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              context.pushNamed(
                                AppRouteNames.createProgramExercise,
                                pathParameters: {'programId': program.id},
                                extra: program,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _orange,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: _orange.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  // SizedBox(width: 6),
                                  // Text(
                                  //   '',
                                  //   style: TextStyle(
                                  //     color: Colors.white,
                                  //     fontWeight: FontWeight.w600,
                                  //     fontSize: 14,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // لیست روزها
                      BlocBuilder<ProgramExerciseCubit, ProgramExerciseState>(
                        builder: (context, state) {
                          return switch (state) {
                            ProgramExerciseLoading() => const Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: _orange,
                                ),
                              ),
                            ),
                            ProgramExerciseError(:final message) => Center(
                              child: Text(
                                message,
                                style: const TextStyle(color: _charcoal),
                              ),
                            ),
                            ProgramExerciseLoaded(:final exercises) =>
                              exercises.isEmpty
                                  ? const _EmptyExercisesState()
                                  : _buildExercisesByDay(context, exercises),
                            _ => const SizedBox(),
                          };
                        },
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

  Widget _buildExercisesByDay(
    BuildContext context,
    List<ProgramExerciseDetails> exercises,
  ) {
    final grouped = _groupByDay(exercises);
    final sortedDays = grouped.keys.toList()..sort();

    return Column(
      children: sortedDays.map((day) {
        final dayExercises = grouped[day]!;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _GlassCard(
            child: Material(
              color: Colors.transparent,
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(top: 8),
                  initiallyExpanded: true,
                  title: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: const TextStyle(
                              color: _orange,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'روز $day',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _charcoal,
                        ),
                      ),
                    ],
                  ),
                  children: dayExercises.map((details) {
                    final pe = details.programExercise;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // هدر سیستم تمرینی
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  pe.trainingSystem.name,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: _charcoal,
                                  ),
                                ),
                              ),
                              Text(
                                '${pe.sets} ست • ${pe.rest} استراحت',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _charcoal,
                                ),
                              ),
                              const SizedBox(width: 12),
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                iconSize: 18,
                                color: _cream,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      context.pushNamed(
                                        AppRouteNames.editProgramExercise,
                                        pathParameters: {
                                          'programId': program.id,
                                          'programExerciseId': pe.id,
                                        },
                                        extra: ProgramExerciseConfigurationArgs(
                                          program: program,
                                          draft: ProgramExerciseDraft(
                                            programId: program.id,
                                            day: pe.day,
                                            trainingSystem: pe.trainingSystem,
                                          ),
                                          exercises: details.items
                                              .map((e) => e.exercise)
                                              .toList(),
                                          existingExercise: pe,
                                        ),
                                      );
                                      break;
                                    case 'delete':
                                      () async {
                                        final result = await showDialog<bool>(
                                          context: context,

                                          builder: (_) => DeleteDialog(
                                            itemName: '',
                                            title: 'تمرین',
                                          ),
                                        );

                                        if (result == true && context.mounted) {
                                          context
                                              .read<ProgramExerciseCubit>()
                                              .deleteExercise(pe.id);
                                        }
                                      }.call();

                                      break;
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('ویرایش'),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'حذف',
                                      style: TextStyle(color: _orange),
                                    ),
                                  ),
                                ],
                                child: Icon(
                                  Icons.more_horiz_rounded,
                                  size: 20,
                                  color: _charcoal,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // آیتم‌های تمرین
                          ...details.items.map((itemDetails) {
                            final item = itemDetails.item;
                            final exercise = itemDetails.exercise;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      exercise.name,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: _charcoal,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${item.reps} تکرار •',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _charcoal,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'تمپو ${item.tempo}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _charcoal,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// -------------------- Widgets کمکی --------------------

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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.38),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.55),
              width: 1.1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  static const Color _orange = Color(0xFFFF6B35);
  static const Color _charcoal = Color(0xFF2D2D2D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _orange),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: _charcoal,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyExercisesState extends StatelessWidget {
  const _EmptyExercisesState();

  static const Color _charcoal = Color(0xFF2D2D2D);
  static const Color _orange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 32,
                color: _orange,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تمرینی در برنامه وجود ندارد!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _charcoal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'اولین تمرین را اضافه کنید',
              style: TextStyle(fontSize: 13, color: _charcoal.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
