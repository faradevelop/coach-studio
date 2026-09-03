// lib/features/exercises/presentation/pages/edit_exercise_page.dart
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:coach_studio/features/exercises/presentation/widgets/exercise_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EditExercisePage extends StatelessWidget {
  final String exerciseId;
  final Exercise? seedExercise;

  const EditExercisePage({
    super.key,
    required this.exerciseId,
    this.seedExercise,
  });

  Exercise? _resolve(ExerciseState state) {
    if (state is ExerciseLoaded) {
      for (final e in state.exercises) {
        if (e.id == exerciseId) return e;
      }
    }
    return seedExercise;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ExerciseCubit, ExerciseState>(
        builder: (context, state) {
          final exercise = _resolve(state);
          if (exercise == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final isLoading = state is ExerciseLoaded && state.isSubmitting;
          return ExerciseForm(
            initialExercise: exercise,
            isLoading: isLoading,
            onSubmit: (updatedExercise) async {
              final success = await context
                  .read<ExerciseCubit>()
                  .updateExercise(updatedExercise);
              if (!context.mounted) return;
              if (!success) {
                sl<AppNotification>().error('ویرایش تمرین ناموفق بود.');
                return;
              }
              sl<AppNotification>().success('تمرین با موفقیت ویرایش شد.');
              context.pop();
            },
          );
        },
      ),
    );
  }
}
