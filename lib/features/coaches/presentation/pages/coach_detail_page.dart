import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/core/widgets/navigation/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';
import 'package:coach_studio/features/coaches/presentation/cubit/coach_cubit.dart';
import 'package:coach_studio/features/coaches/presentation/cubit/coach_state.dart';
import 'package:coach_studio/features/coaches/presentation/widgets/coach_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CoachDetailPage extends StatelessWidget {
  final String coachId;
  final AuthUser? seedCoach;

  const CoachDetailPage({super.key, required this.coachId, this.seedCoach});

  AuthUser? _resolve(CoachState state) {
    if (state is CoachLoaded) {
      for (final c in state.coaches) {
        if (c.id == coachId) return c;
      }
    }
    return seedCoach;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoachCubit, CoachState>(
      builder: (context, state) {
        final coach = _resolve(state);
        if (coach == null) {
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
        return _CoachDetailView(coach: coach);
      },
    );
  }
}

class _CoachDetailView extends StatefulWidget {
  final AuthUser coach;
  const _CoachDetailView({required this.coach});

  @override
  State<_CoachDetailView> createState() => _CoachDetailViewState();
}

class _CoachDetailViewState extends State<_CoachDetailView> {
  bool _busy = false;

  Future<void> _toggleStatus() async {
    final coach = widget.coach;
    final activate = !coach.isActive;

    if (!activate) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AppConfirmDialog(
          destructive: true,
          color: AppColors.error,
          icon: const Icon(
            Icons.person_off_rounded,
            size: 22,
            color: AppColors.error,
          ),
          title: 'غیرفعال‌سازی مربی',
          message:
              'مربی «${coach.displayName}» دیگر نمی‌تواند وارد شود و نشست‌های فعالش بسته می‌شود. اطلاعات او حذف نخواهد شد.',
          confirmText: 'غیرفعال‌سازی',
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() => _busy = true);
    final error = await context.read<CoachCubit>().setActive(coach, activate);
    if (!mounted) return;
    setState(() => _busy = false);

    if (error != null) {
      sl<AppNotification>().error(error);
      return;
    }
    sl<AppNotification>().success(
      activate ? 'مربی فعال شد.' : 'مربی غیرفعال شد.',
    );
  }

  static String _orDash(String? value) =>
      (value == null || value.trim().isEmpty) ? '—' : value;

  @override
  Widget build(BuildContext context) {
    final coach = widget.coach;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            MaxWidthBox(
              maxWidth: AppContentWidth.detail,
              child: InnerPagesAppBar(
                rightButton: null,
                title: coach.displayName,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: MaxWidthBox(
                  maxWidth: AppContentWidth.form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppSurface(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _InfoRow(
                              label: 'نام',
                              value: _orDash(coach.firstName),
                              ltr: false,
                            ),
                            _InfoRow(
                              label: 'نام خانوادگی',
                              value: _orDash(coach.lastName),
                              ltr: false,
                            ),
                            _InfoRow(
                              label: 'نام کاربری',
                              value: coach.username,
                            ),
                            _InfoRow(
                              label: 'شماره موبایل',
                              value: _orDash(coach.phone),
                            ),
                            _InfoRow(
                              label: 'ایمیل',
                              value: _orDash(coach.email),
                            ),
                            _InfoRow(label: 'نقش', value: coach.role.label),
                            Row(
                              children: [
                                Text('وضعیت', style: AppTextStyles.bodySmall),
                                const Spacer(),
                                CoachStatusChip(isActive: coach.isActive),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        text: coach.isActive ? 'غیرفعال‌سازی' : 'فعال‌سازی',
                        variant: coach.isActive
                            ? AppButtonVariant.destructive
                            : AppButtonVariant.primary,
                        isLoading: _busy,
                        onPressed: _busy ? null : _toggleStatus,
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool ltr;
  const _InfoRow({required this.label, required this.value, this.ltr = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(width: 16),
          Expanded(
            child: Directionality(
              textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
              child: Text(
                value,
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
