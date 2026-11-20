import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/features/authentication/domain/entities/auth_user.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_state.dart';
import 'package:coach_studio/features/settings/presentation/widgets/change_password_dialog.dart';
import 'package:coach_studio/features/settings/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutConfirmationDialog(),
    );

    if (result == true && context.mounted) {
      await context.read<AuthCubit>().logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'تنظیمات',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, state) {
                    if (state is! AuthAuthenticated) {
                      return const SizedBox();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProfileCard(user: state.user),
                        const SizedBox(height: AppSpacing.xl),
                        _SettingsActionTile(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedLockSync01,
                            size: 20,
                            color: AppColors.secondary,
                          ),
                          title: 'تغییر رمز عبور',
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (_) => const ChangePasswordDialog(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _SettingsActionTile(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedLogout01,
                            size: 20,
                            color: AppColors.secondary,
                          ),
                          title: 'خروج از حساب',
                          onTap: () => _confirmLogout(context),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final AuthUser user;

  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final email = user.email;

    return AppSurface(
      padding: const EdgeInsets.all(18),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: const Icon(
                      CupertinoIcons.person_fill,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 1, 14, 5),
                        decoration: BoxDecoration(
                          color: AppColors.secondarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Text(
                          user.role.label,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 5, top: 4),
                        child: Text(
                          user.displayName,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            _ProfileInfoRow(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedUserAccount,
                size: 18,
                color: AppColors.primary,
              ),
              label: 'نام کاربری',
              value: user.username,
            ),
            Divider(indent: 36, height: 20),
            _ProfileInfoRow(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedSmartphone,
                size: 18,
                color: AppColors.primary,
              ),
              label: 'شماره موبایل',
              value: user.phone.persianNumber,
            ),

            Divider(indent: 36, height: 20),
            _ProfileInfoRow(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedMail01,
                size: 18,
                color: AppColors.primary,
              ),
              label: 'ایمیل',
              value: (email != null && email.isNotEmpty) ? email : '-',
              ltr: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final bool ltr;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.ltr = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.15),
            borderRadius: BorderRadius.all(Radius.circular(9)),
          ),
          child: icon,
        ),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.bodySmall),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              value,
              textAlign: TextAlign.end,
              textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      radius: AppRadius.lg,
      elevated: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: icon,
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: AppTextStyles.label)),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: AppColors.textPrimary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
