import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/widgets/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/delete_dialog.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/workout_program_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class WorkoutProgramListPage extends StatelessWidget {
  const WorkoutProgramListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WorkoutProgramListView();
  }
}

class _WorkoutProgramListView extends StatelessWidget {
  const _WorkoutProgramListView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: CustomAppBar(
              onPressed: () {
                context.pushNamed(AppRouteNames.createWorkoutProgram);
              },
              title: 'برنامه‌های تمرینی',
            ),
          ),
          SizedBox(height: 28),
          Expanded(
            child: BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
              builder: (context, state) {
                return switch (state) {
                  WorkoutProgramInitial() => const SizedBox(),

                  WorkoutProgramLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  WorkoutProgramLoaded(:final programs) =>
                    programs.isEmpty
                        ? _EmptyProgramsState()
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              int crossAxisCount;
                              double childAspectRatio;

                              if (width >= 1100) {
                                // desktop
                                crossAxisCount = 4;
                                childAspectRatio = 2;
                              } else if (width >= 700) {
                                // tablet
                                crossAxisCount = 3;
                                childAspectRatio = 1.5;
                              } else {
                                // mobile
                                crossAxisCount = 2;
                                childAspectRatio = 1.3;
                              }
                              return GridView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  14,
                                  12,
                                  14,
                                  100,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount, //2,
                                      mainAxisSpacing: 14,
                                      crossAxisSpacing: 14,
                                      childAspectRatio: childAspectRatio, //1.5,
                                    ),
                                itemCount: programs.length,
                                itemBuilder: (context, index) {
                                  final program = programs[index];
                                  return WorkoutProgramCard(
                                    program: program,
                                    // onEdit: () {
                                    //   context.pushNamed(
                                    //     AppRouteNames.workoutProgramDetail,
                                    //     pathParameters: {'programId': program.id},
                                    //     extra: program,
                                    //   );
                                    // },
                                    onDelete: () async {
                                      final result = await showDialog<bool>(
                                        context: context,

                                        builder: (_) => DeleteDialog(
                                          itemName: program.title,
                                          title: 'برنامه',
                                        ),
                                      );

                                      if (result == true && context.mounted) {
                                        await context
                                            .read<WorkoutProgramCubit>()
                                            .deleteProgram(program.id);
                                      }
                                    },
                                    onTap: () {
                                      context.pushNamed(
                                        AppRouteNames.workoutProgramDetail,
                                        pathParameters: {
                                          'programId': program.id,
                                        },
                                        extra: program,
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),

                  WorkoutProgramError(:final message) => Center(
                    child: Text(message),
                  ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProgramsState extends StatelessWidget {
  const _EmptyProgramsState();

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
              'No workout programs yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _charcoal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create your first program',
              style: TextStyle(fontSize: 13, color: _charcoal.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
