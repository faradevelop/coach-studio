import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/widgets/workout_program_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateWorkoutProgramPage extends StatelessWidget {
  final WorkoutProgram? existingProgram;
  const CreateWorkoutProgramPage({super.key, this.existingProgram});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<WorkoutProgramCubit>(),
      child: _CreateWorkoutProgramView(existingProgram: existingProgram),
    );
  }
}

class _CreateWorkoutProgramView extends StatelessWidget {
  final WorkoutProgram? existingProgram;
  const _CreateWorkoutProgramView({this.existingProgram});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          existingProgram == null ? 'Create Program' : 'Edit Program',
        ),
      ),
      body: WorkoutProgramForm(
        initialProgram: existingProgram,
        onSubmit: (program) async {
          if (existingProgram == null) {
            final createdProgram = await context
                .read<WorkoutProgramCubit>()
                .addProgram(program);

            if (createdProgram != null && context.mounted) {
              // context.goNamed(
              //   AppRouteNames.workoutProgramDetail,
              //   pathParameters: {'programId': createdProgram.id},
              //   extra: createdProgram,
              // );
              context.pushReplacementNamed(
                AppRouteNames.workoutProgramDetail,
                pathParameters: {'programId': createdProgram.id},
                extra: createdProgram,
              );
            }
          } else {
            await context.read<WorkoutProgramCubit>().updateProgram(program);

            if (context.mounted) {
              context.pop();
            }
          }
        },
      ),
    );
  }
}
