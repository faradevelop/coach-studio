import 'dart:ui';
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.70),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.55),
                width: 1.2,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedLockSync01,
                      size: 28,
                      color: AppColors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'تغییر رمز عبور',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 22),
                  AppTextField(
                    controller: _currentPasswordController,
                    label: 'رمز عبور فعلی',
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'الزامی' : null,
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
                        child: GestureDetector(
                          onTap: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: Container(
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            child: const Text(
                              'انصراف',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.charcoal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: 'تایید',
                          isLoading: _isSubmitting,
                          onPressed: _isSubmitting ? null : _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
