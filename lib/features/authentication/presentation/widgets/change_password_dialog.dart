import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_dialog.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await context.read<AuthCubit>().changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
      _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (!success) {
      setState(() => _isSubmitting = false);
      sl<AppNotification>().error(
        'تغییر رمز عبور ناموفق بود. رمز عبور فعلی را بررسی کنید.',
      );
      return;
    }

    // Backend revokes all tokens on a successful password change — close
    // this dialog; AuthCubit has already moved to Unauthenticated, so the
    // router will take the user back to the login screen right after.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    sl<AppNotification>().success(
      'رمز عبور با موفقیت تغییر کرد. لطفاً دوباره وارد شوید.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedLockSync01,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تغییر رمز عبور',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 22),
            AppTextField(
              controller: _currentPasswordController,
              label: 'رمز عبور فعلی',
              obscureText: true,
              validator: (v) => (v == null || v.isEmpty) ? 'الزامی' : null,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _newPasswordController,
              label: 'رمز عبور جدید',
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'الزامی';
                if (v.length < 8) return 'حداقل ۸ کاراکتر';
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _confirmPasswordController,
              label: 'تکرار رمز عبور جدید',
              obscureText: true,
              validator: (v) {
                if (v == null || v.isEmpty) return 'الزامی';
                if (v != _newPasswordController.text) {
                  return 'رمز عبور مطابقت ندارد';
                }
                return null;
              },
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'انصراف',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.compact,
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'تایید',
                    size: AppButtonSize.compact,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
