import 'dart:typed_data';

import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/app/routing/route_args/program_exercise_configuration_args.dart';
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
import 'package:pdf/pdf.dart';
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

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Exercise'),
          content: const Text('Are you sure?'),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () async {
                await context.read<ProgramExerciseCubit>().deleteExercise(id);
                if (context.mounted) {
                  context.pop();
                }
              },

              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  ///////////////////////
  Future<void> _previewPdf(BuildContext context) async {
    final state = context.read<ProgramExerciseCubit>().state;

    if (state is! ProgramExerciseLoaded || state.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا حداقل یک تمرین اضافه کنید')),
      );
      return;
    }

    // دیتای ورزشکار (میتونی از حالت یا دیفالت استفاده کنی)
    final athlete = AthleteInfo(
      fullName: 'ورزشکار',
      weight: '--',
      height: '--',
      date: DateTime.now(),
    );

    final details = WorkoutProgramDetails(
      program: program,
      exercises: state.exercises,
    );

    // تولید PDF
    final bytes = await WorkoutProgramPdfGenerator().generate(
      details: details,
      athlete: athlete,
    );

    if (!context.mounted) return;

    // ✅ نمایش پیش‌نمایش PDF
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfPreview(
          build: (format) async => bytes,
          canChangeOrientation: true,
          canChangePageFormat: true,
          canDebug: true,
          allowPrinting: true,
          allowSharing: true,
          initialPageFormat: PdfPageFormat.a4,
          onError: (context, error) {
            print('PDF Error: $error');
            return Text('eeeeeeeeeeeeeeeeeeeeee');
          },
        ),
      ),
    );
  }
  ////////////////////////

  // یک متد جدید داخل _WorkoutProgramDetailView
  Future<void> _generatePdf(BuildContext context) async {
    final state = context.read<ProgramExerciseCubit>().state;

    if (state is! ProgramExerciseLoaded || state.exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا حداقل یک تمرین اضافه کنید')),
      );
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
      appBar: AppBar(
        title: Text(program.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Generate PDF',
            onPressed: () => _generatePdf(context),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text('Goal: ${program.goal.name}'),
            Text('Level: ${program.level.name}'),
            Text('Days: ${program.daysPerWeek}'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Text(
                  'Exercises',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                FilledButton.icon(
                  onPressed: () {
                    context.pushNamed(
                      AppRouteNames.createProgramExercise,
                      pathParameters: {'programId': program.id},
                      extra: program,
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Exercise'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Expanded(
              child: BlocBuilder<ProgramExerciseCubit, ProgramExerciseState>(
                builder: (context, state) {
                  return switch (state) {
                    ProgramExerciseLoading() => const Center(
                      child: CircularProgressIndicator(),
                    ),

                    ProgramExerciseError(:final message) => Center(
                      child: Text(message),
                    ),

                    ProgramExerciseLoaded(:final exercises) =>
                      exercises.isEmpty
                          ? const Center(child: Text('No exercises added yet'))
                          : _buildExercisesByDay(context, exercises),

                    _ => const SizedBox(),
                  };
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesByDay(
    BuildContext context,
    List<ProgramExerciseDetails> exercises,
  ) {
    final grouped = _groupByDay(exercises);

    return ListView(
      children: grouped.entries.map((entry) {
        final day = entry.key;
        final dayProgramExercises = entry.value;

        return ExpansionTile(
          title: Text('Day $day'),

          children: dayProgramExercises.map((details) {
            final programExercise = details.programExercise;

            return ExpansionTile(
              title: Text(programExercise.trainingSystem.name),

              subtitle: Text(
                '${programExercise.sets} sets | '
                '${programExercise.rest} rest',
              ),

              children: details.items.map((itemDetails) {
                final item = itemDetails.item;
                final exercise = itemDetails.exercise;

                return ListTile(
                  title: Text(exercise.name),

                  subtitle: Text(
                    '${item.reps} reps | '
                    'Tempo ${item.tempo}',
                  ),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          context.pushNamed(
                            AppRouteNames.editProgramExercise,
                            pathParameters: {
                              'programId': program.id,
                              'programExerciseId': programExercise.id,
                            },
                            extra: ProgramExerciseConfigurationArgs(
                              program: program,
                              draft: ProgramExerciseDraft(
                                programId: program.id,
                                day: programExercise.day,
                                trainingSystem: programExercise.trainingSystem,
                              ),
                              exercises: details.items
                                  .map((itemDetails) => itemDetails.exercise)
                                  .toList(),
                              existingExercise: programExercise,
                            ),
                          );
                          break;

                        case 'delete':
                          _showDeleteDialog(context, programExercise.id);
                          break;
                      }
                    },

                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                );
              }).toList(),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
