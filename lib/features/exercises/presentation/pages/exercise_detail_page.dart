import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_surface.dart';
import 'package:coach_studio/core/widgets/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/delete_dialog.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/core/widgets/app_info_chip.dart';
import 'package:coach_studio/features/exercises/domain/entities/exercise.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_cubit.dart';
import 'package:coach_studio/features/exercises/presentation/cubit/exercise_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Admin-only (registered only in AdminRouter).
class ExerciseDetailPage extends StatelessWidget {
  final String exerciseId;
  final Exercise? seedExercise;

  const ExerciseDetailPage({
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
    return BlocBuilder<ExerciseCubit, ExerciseState>(
      builder: (context, state) {
        final exercise = _resolve(state);
        if (exercise == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.primary,
                size: 40,
              ),
            ),
          );
        }
        return _ExerciseDetailView(exercise: exercise);
      },
    );
  }
}

class _ExerciseDetailView extends StatefulWidget {
  final Exercise exercise;
  const _ExerciseDetailView({required this.exercise});

  @override
  State<_ExerciseDetailView> createState() => _ExerciseDetailViewState();
}

class _ExerciseDetailViewState extends State<_ExerciseDetailView> {
  bool _isDeleting = false;

  Future<void> _delete() async {
    final e = widget.exercise;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteDialog(itemName: e.name, title: 'تمرین'),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);
    final ok = await context.read<ExerciseCubit>().deleteExercise(e.id);
    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (!ok) {
      sl<AppNotification>().error('حذف تمرین ناموفق بود.');
      return;
    }
    sl<AppNotification>().success('تمرین با موفقیت حذف شد.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.exercise;
    final imageUrl = e.imageUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            MaxWidthBox(
              maxWidth: AppContentWidth.detail,
              child: InnerPagesAppBar(rightButton: null, title: e.name),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: MaxWidthBox(
                  maxWidth: AppContentWidth.detail,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSurface(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageUrl != null && imageUrl.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.field,
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (e.type != null) AppInfoChip.plain(text: e.type!.label),
                                AppInfoChip.plain(text: e.difficulty.label),
                                AppInfoChip.plain(text: e.equipment.label),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _Section(
                              title: 'عضلات هدف',
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  for (final m in e.targetMuscles)
                                    AppInfoChip.plain(text: m.name),
                                ],
                              ),
                            ),
                            _TextSection('توضیح', e.description),
                            _TextSection('نحوه اجرا', e.instructions),
                            _TextSection('اشتباهات رایج', e.mistakes),
                            _TextSection('لینک ویدیو', e.videoUrl),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        text: 'ویرایش',
                        onPressed: _isDeleting
                            ? null
                            : () => context.pushNamed(
                                AppRouteNames.editExercise,
                                pathParameters: {'exerciseId': e.id},
                                extra: e,
                              ),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        text: 'حذف',
                        variant: AppButtonVariant.destructive,
                        isLoading: _isDeleting,
                        onPressed: _isDeleting ? null : _delete,
                      ),
                    ],
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

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  final String title;
  final String? text;
  const _TextSection(this.title, this.text);

  @override
  Widget build(BuildContext context) {
    final value = text?.trim();
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return _Section(
      title: title,
      child: Text(value, style: AppTextStyles.body),
    );
  }
}
