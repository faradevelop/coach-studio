import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/dialogs/delete_dialog.dart';
import 'package:coach_studio/core/widgets/display/app_glass_surface.dart';
import 'package:coach_studio/core/widgets/display/app_info_chip.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/program_exercise_details.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/program_exercise_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class ProgramExerciseCard extends StatelessWidget {
  final ProgramExerciseDetails details;
  final WorkoutProgram program;

  const ProgramExerciseCard({
    super.key,
    required this.details,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    final programExercise = details.programExercise;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppGlassSurface(
        blur: true,
        blurSigma: 10,
        radius: AppRadius.md + 4,
        padding: const EdgeInsets.all(0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md + 5),
            border: Border(
              right: BorderSide(color: AppColors.primaryLight, width: 3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      // border: Border.all(color: AppColors.accent, width: 1.2),
                      borderRadius: BorderRadius.circular(AppRadius.sm + 2),
                    ),
                    child: Center(
                      child: Text(
                        programExercise.order.persianNumber,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppInfoChip(
                      text: programExercise.trainingSystem.label,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ExerciseActionsMenu(program: program, details: details),
                ],
              ),
              const SizedBox(height: 10),

              for (final itemDetails in details.items) ...[
                ExerciseItemCard(itemDetails: itemDetails),
                if (itemDetails == details.items.last)
                  ExerciseRestLabel(programExercise: programExercise),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ExerciseRestLabel extends StatelessWidget {
  const ExerciseRestLabel({super.key, required this.programExercise});

  final ProgramExercise programExercise;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 30,
      padding: EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.2),
        // border: Border.all(color: AppColors.accent, width: 1.2),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedStopWatch,
            color: AppColors.accent,
            size: 20,
            strokeWidth: 1.8,
          ),
          SizedBox(width: 4),
          Text(
            '${programExercise.rest.persianNumber} ثانیه استراحت ',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

enum _ExerciseMenuAction { edit, delete }

class ExerciseActionsMenu extends StatelessWidget {
  final WorkoutProgram program;
  final ProgramExerciseDetails details;

  const ExerciseActionsMenu({
    super.key,
    required this.program,
    required this.details,
  });

  ProgramExercise get _programExercise => details.programExercise;

  void _edit(BuildContext context) {
    context.pushNamed(
      AppRouteNames.editProgramExercise,
      pathParameters: {
        'programId': program.id,
        'programExerciseId': _programExercise.id,
      },
      extra: details,
    );
  }

  Future<void> _delete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const DeleteDialog(itemName: '', title: 'تمرین'),
    );

    if (result != true || !context.mounted) return;

    final success = await context.read<ProgramExerciseCubit>().deleteExercise(
      _programExercise.id,
    );
    if (!success) {
      sl<AppNotification>().error('حذف تمرین ناموفق بود.');
      return;
    }

    sl<AppNotification>().success('تمرین با موفقیت حذف شد.');
  }

  @override
  Widget build(BuildContext context) {
    // Colour / shape / elevation come from AppTheme.popupMenuTheme.
    return PopupMenuButton<_ExerciseMenuAction>(
      padding: EdgeInsets.zero,
      iconSize: 18,
      position: PopupMenuPosition.under,
      menuPadding: EdgeInsets.zero,
      onSelected: (action) async {
        switch (action) {
          case _ExerciseMenuAction.edit:
            _edit(context);
          case _ExerciseMenuAction.delete:
            await _delete(context);
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _ExerciseMenuAction.edit,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: HugeIcon(icon: HugeIcons.strokeRoundedEdit02, size: 16),
              ),
              SizedBox(width: 2),
              Text('ویرایش'),
            ],
          ),
        ),
        PopupMenuDivider(height: 0.8, indent: 10, endIndent: 10),
        PopupMenuItem(
          value: _ExerciseMenuAction.delete,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.all(5),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedDelete02,
                  size: 16,
                  color: AppColors.error,
                ),
              ),
              SizedBox(width: 2),
              Text('حذف', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ],
      child: Container(
        width: 26,
        height: 26,
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: AppColors.outline,
          borderRadius: BorderRadius.circular(10),
        ),
        child: HugeIcon(
          icon: HugeIcons.strokeRoundedMoreHorizontal,
          size: 10,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class ExerciseItemCard extends StatelessWidget {
  final ProgramExerciseItemDetails itemDetails;

  const ExerciseItemCard({super.key, required this.itemDetails});

  @override
  Widget build(BuildContext context) {
    final item = itemDetails.item;
    final description = item.description;
    final hasDescription = description != null && description.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itemDetails.exercise.name,
            style: AppTextStyles.body.copyWith(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 8),
          if (hasDescription)
            Text(
              description,
              style: AppTextStyles.body.copyWith(fontSize: 12.5),
              maxLines: 3,
            ),
          Divider(
            color: AppColors.primary.withValues(alpha: 0.25),
            height: 12,
            thickness: 1,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AppInfoChip(
                icon: _chipIcon(HugeIcons.strokeRoundedRepeat),
                text: '${item.reps.join(' - ')}  تکرار ',
              ),
              const SizedBox(width: 10),
              if (item.tempo != '-')
                AppInfoChip(
                  icon: _chipIcon(HugeIcons.strokeRoundedPendulum),
                  text: '${item.tempo}  تمپو ',
                ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _chipIcon(List<List<dynamic>> icon) => HugeIcon(
    icon: icon,
    color: AppColors.secondary,
    size: 14,
    strokeWidth: 2,
  );
}
