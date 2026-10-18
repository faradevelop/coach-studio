import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/core/widgets/inputs/app_text_field.dart';
import 'package:coach_studio/core/widgets/navigation/custom_app_bar.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final success = await context.read<AuthCubit>().forgotPassword(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        sl<AppNotification>().success(
          'در صورت وجود این ایمیل در سیستم، لینک بازیابی رمز عبور ارسال شد.',
        );
        context.pop();
      } else {
        sl<AppNotification>().error('درخواست بازیابی رمز عبور ناموفق بود.');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // The empty 40px box on the leading side keeps the title centred
            // against the back button on the trailing side.
            const InnerPagesAppBar(
              rightButton: SizedBox(width: 40),
              title: 'فراموشی رمز عبور',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  children: [
                    Text(
                      'ایمیل خود را وارد کنید تا لینک بازیابی رمز عبور برای شما ارسال شود.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(height: 24),
                    AppSurface(
                      padding: const EdgeInsets.all(22),
                      child: SizedBox(
                        width: double.infinity,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppTextField(
                                controller: _emailController,
                                label: 'ایمیل',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'الزامی';
                                  }
                                  if (!value.contains('@')) {
                                    return 'ایمیل معتبر وارد کنید';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              AppButton(
                                text: 'ارسال لینک بازیابی',
                                isLoading: _isSubmitting,
                                onPressed: _isSubmitting ? null : _submit,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
