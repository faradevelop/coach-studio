import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
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

class _CreateWorkoutProgramView extends StatefulWidget {
  final WorkoutProgram? existingProgram;
  const _CreateWorkoutProgramView({this.existingProgram});

  @override
  State<_CreateWorkoutProgramView> createState() =>
      _CreateWorkoutProgramViewState();
}

class _CreateWorkoutProgramViewState extends State<_CreateWorkoutProgramView> {
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WorkoutProgramForm(
        initialProgram: widget.existingProgram,
        isLoading: isSubmitting,
        onSubmit: (program) async {
          setState(() => isSubmitting = true);

          try {
            if (widget.existingProgram == null) {
              final createdProgram = await context
                  .read<WorkoutProgramCubit>()
                  .addProgram(program);
              if (!context.mounted) return;

              if (createdProgram == null) {
                sl<AppNotification>().error('افزودن برنامه ناموفق بود.');
                return;
              }

              sl<AppNotification>().success('برنامه با موفقیت اضافه شد.');
              context.pushReplacementNamed(
                AppRouteNames.workoutProgramDetail,
                pathParameters: {'programId': createdProgram.id},
                extra: createdProgram,
              );
            } else {
              final success = await context
                  .read<WorkoutProgramCubit>()
                  .updateProgram(program);
              if (!context.mounted) return;

              if (!success) {
                sl<AppNotification>().error('ویرایش برنامه ناموفق بود.');
                return;
              }

              sl<AppNotification>().success('برنامه با موفقیت ویرایش شد.');
              context.pop();
            }
          } finally {
            if (mounted) {
              setState(() => isSubmitting = false);
            }
          }
        },
      ),
    );
  }
}
