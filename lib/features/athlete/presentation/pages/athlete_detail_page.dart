import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/localization/formatters/app_date_formatter.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:coach_studio/core/widgets/display/app_info_chip.dart';
import 'package:coach_studio/core/widgets/display/app_status_chip.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
import 'package:coach_studio/core/widgets/navigation/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete_program_assignment.dart';
import 'package:coach_studio/features/athlete/domain/repositories/athlete_repository.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_cubit.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_detail_cubit.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_detail_state.dart';
import 'package:coach_studio/features/athlete/presentation/widgets/assign_program_dialog.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AthleteDetailPage extends StatelessWidget {
  final String athleteId;
  const AthleteDetailPage({super.key, required this.athleteId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AthleteDetailCubit(
        athleteId: athleteId,
        repository: sl<AthleteRepository>(),
        listCubit: context.read<AthleteCubit>(),
        logger: sl<AppLogger>(),
      )..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const MaxWidthBox(
                maxWidth: AppContentWidth.detail,
                child: InnerPagesAppBar(
                  rightButton: null,
                  title: 'جزئیات ورزشکار',
                ),
              ),
              Expanded(
                child: BlocBuilder<AthleteDetailCubit, AthleteDetailState>(
                  builder: (context, state) => switch (state) {
                    AthleteDetailLoading() => Center(
                      child: LoadingAnimationWidget.hexagonDots(
                        color: AppColors.primary,
                        size: 40,
                      ),
                    ),
                    AthleteDetailError() => AppErrorState(
                      onRetry: () => context.read<AthleteDetailCubit>().load(),
                    ),
                    AthleteDetailLoaded() => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      child: MaxWidthBox(
                        maxWidth: AppContentWidth.detail,
                        child: _Body(state: state),
                      ),
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final AthleteDetailLoaded state;
  const _Body({required this.state});

  Athlete get athlete => state.athlete;
  bool get busy => state.isSubmitting;

  static String _weight(double w) =>
      w == w.roundToDouble() ? w.toInt().toString() : w.toString();

  void _openProgram(BuildContext context, AthleteProgramAssignment a) {
    context.pushNamed(
      AppRouteNames.workoutProgramDetail,
      pathParameters: {'programId': a.programId},
      extra: a.program,
    );
  }

  Future<void> _edit(BuildContext context) async {
    final cubit = context.read<AthleteDetailCubit>();
    await context.pushNamed(
      AppRouteNames.editAthlete,
      pathParameters: {'athleteId': athlete.id},
      extra: athlete,
    );
    if (!context.mounted) return;
    cubit.load(silent: true);
  }

  Future<void> _assign(BuildContext context) async {
    final programsState = context.read<WorkoutProgramCubit>().state;
    if (programsState is! WorkoutProgramLoaded ||
        programsState.programs.isEmpty) {
      sl<AppNotification>().warning('ابتدا یک برنامه‌ی تمرینی ایجاد کنید.');
      return;
    }
    final result = await showDialog<AssignProgramResult>(
      context: context,
      builder: (_) => AssignProgramDialog(
        programs: programsState.programs,
        replacesCurrent: athlete.currentAssignment != null,
      ),
    );
    if (result == null || !context.mounted) return;

    final error = await context.read<AthleteDetailCubit>().assignProgram(
      result.sourceProgramId,
      result.title,
    );
    if (error != null) {
      sl<AppNotification>().error(error);
      return;
    }
    sl<AppNotification>().success('برنامه با موفقیت اختصاص داده شد.');
  }

  Future<void> _toggleArchive(BuildContext context) async {
    final cubit = context.read<AthleteDetailCubit>();
    if (!athlete.isArchived) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AppConfirmDialog(
          destructive: true,
          color: AppColors.error,
          icon: const Icon(
            Icons.archive_rounded,
            size: 22,
            color: AppColors.error,
          ),
          title: 'بایگانی ورزشکار',
          message:
              'ورزشکار «${athlete.fullName}» بایگانی می‌شود. اطلاعات او حذف نخواهد شد و هر زمان قابل بازگردانی است.',
          confirmText: 'بایگانی',
        ),
      );
      if (ok != true) return;
    }
    final error = athlete.isArchived
        ? await cubit.restore()
        : await cubit.archive();
    if (error != null) {
      sl<AppNotification>().error(error);
      return;
    }
    sl<AppNotification>().success(
      athlete.isArchived ? 'ورزشکار بازگردانی شد.' : 'ورزشکار بایگانی شد.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = athlete;
    final hasHealth = [
      a.injuries,
      a.physicalLimitations,
      a.coachNotes,
    ].any((v) => v != null && v.trim().isNotEmpty);
    final previous = state.history.where((h) => !h.isCurrent).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        AppSurface(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.fullName,
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    AppStatusChip(
                      label: a.isArchived ? 'بایگانی‌شده' : 'فعال',
                      type: a.isArchived
                          ? AppStatusType.warning
                          : AppStatusType.success,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (a.isArchived) ...[
          const SizedBox(height: 10),
          Text(
            'این ورزشکار بایگانی شده است؛ برای ویرایش یا اختصاص برنامه ابتدا او را بازگردانی کنید.',
            style: AppTextStyles.subtitle,
          ),
        ],
        const SizedBox(height: 14),

        _Section(
          title: 'اطلاعات فردی',
          child: Column(
            children: [
              _InfoRow('جنسیت', a.gender?.label),
              _InfoRow(
                'تاریخ تولد',
                a.dateOfBirth == null
                    ? null
                    : '${AppDateFormatter.toPersianDate(a.dateOfBirth!)} (${a.age} سال)'
                          .persianNumber,
              ),
              _InfoRow('شماره تماس', a.phone?.persianNumber, ltr: true),
              _InfoRow('ایمیل', a.email, ltr: true),
              _InfoRow(
                'قد',
                a.heightCm == null
                    ? null
                    : '${a.heightCm} سانتی‌متر'.persianNumber,
              ),
              _InfoRow(
                'وزن',
                a.weightKg == null
                    ? null
                    : '${_weight(a.weightKg!)} کیلوگرم'.persianNumber,
              ),
              _InfoRow('هدف', a.fitnessGoal?.label),
              _InfoRow('سطح تجربه', a.experienceLevel?.label, last: true),
            ],
          ),
        ),

        if (hasHealth)
          _Section(
            title: 'وضعیت جسمی و یادداشت‌ها',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TextBlock('آسیب‌دیدگی‌ها', a.injuries),
                _TextBlock('محدودیت‌های جسمی', a.physicalLimitations),
                _TextBlock('یادداشت مربی', a.coachNotes),
              ],
            ),
          ),

        _Section(title: 'برنامه‌ی فعلی', child: _current(context)),

        _Section(
          title: 'سابقه‌ی برنامه‌ها',
          child: previous.isEmpty
              ? Text('سابقه‌ای وجود ندارد.', style: AppTextStyles.subtitle)
              : Column(
                  children: [
                    for (final h in previous)
                      _HistoryTile(
                        item: h,
                        onTap: () => _openProgram(context, h),
                      ),
                  ],
                ),
        ),

        const SizedBox(height: 6),
        AppButton(
          text: 'ویرایش',
          onPressed: (busy || a.isArchived) ? null : () => _edit(context),
        ),
        const SizedBox(height: 12),
        AppButton(
          text: a.isArchived ? 'بازگردانی' : 'بایگانی',
          variant: a.isArchived
              ? AppButtonVariant.secondary
              : AppButtonVariant.destructive,
          isLoading: busy,
          onPressed: busy ? null : () => _toggleArchive(context),
        ),
      ],
    );
  }

  Widget _current(BuildContext context) {
    final current = athlete.currentAssignment;
    final canAssign = !busy && !athlete.isArchived;

    if (current == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'برنامه‌ای اختصاص داده نشده است.',
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 12),
          AppButton(
            text: 'اختصاص برنامه',
            size: AppButtonSize.compact,
            onPressed: canAssign ? () => _assign(context) : null,
          ),
        ],
      );
    }

    final program = current.program;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          program?.title ?? '—',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 15),
        ),
        const SizedBox(height: 10),
        if (program != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppInfoChip(text: program.goal.label),
              AppInfoChip(text: program.level.label),
              AppInfoChip(text: '${program.daysPerWeek} روز در هفته'),
            ],
          ),
        const SizedBox(height: 12),
        _InfoRow(
          'تاریخ اختصاص',
          AppDateFormatter.toPersianDate(current.assignedAt).persianNumber,
        ),
        _InfoRow(
          'برنامه‌ی مبدا',
          current.sourceProgramTitle ??
              (current.sourceProgramId == null ? 'حذف شده' : null),
          last: true,
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'مشاهده برنامه',
          size: AppButtonSize.compact,
          onPressed: () => _openProgram(context, current),
        ),
        const SizedBox(height: 10),
        AppButton(
          text: 'تغییر برنامه',
          variant: AppButtonVariant.secondary,
          size: AppButtonSize.compact,
          onPressed: canAssign ? () => _assign(context) : null,
        ),
      ],
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
      padding: const EdgeInsets.only(bottom: 14),
      child: AppSurface(
        padding: const EdgeInsets.all(18),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.label),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool ltr;
  final bool last;
  const _InfoRow(this.label, this.value, {this.ltr = false, this.last = false});

  @override
  Widget build(BuildContext context) {
    final text = (value == null || value!.trim().isEmpty) ? '—' : value!;
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(width: 16),
          Expanded(
            child: Directionality(
              textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
              child: Text(
                text,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  final String title;
  final String? text;
  const _TextBlock(this.title, this.text);

  @override
  Widget build(BuildContext context) {
    final value = text?.trim();
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final AthleteProgramAssignment item;
  final VoidCallback onTap;
  const _HistoryTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final from = AppDateFormatter.toPersianDate(item.assignedAt);
    final to = item.endedAt == null
        ? '—'
        : AppDateFormatter.toPersianDate(item.endedAt!);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppSurface(
        elevated: false,
        onTap: onTap,
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.program?.title ?? '—',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'از $from تا $to'.persianNumber,
                style: AppTextStyles.caption,
              ),
              if (item.sourceProgramTitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  'مبدا: ${item.sourceProgramTitle}',
                  style: AppTextStyles.caption,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
