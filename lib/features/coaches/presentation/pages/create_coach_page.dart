import 'dart:ui';

import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/widgets/app_button.dart';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/core/widgets/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/coaches/presentation/cubit/coach_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateCoachPage extends StatefulWidget {
  const CreateCoachPage({super.key});

  @override
  State<CreateCoachPage> createState() => _CreateCoachPageState();
}

class _CreateCoachPageState extends State<CreateCoachPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'الزامی' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final error = await context.read<CoachCubit>().createCoach(
      username: _username.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      passwordConfirmation: _confirm.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      sl<AppNotification>().error(error);
      return;
    }
    sl<AppNotification>().success('مربی با موفقیت ایجاد شد.');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.bgColors,
            stops: AppColors.bgStops,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const MaxWidthBox(
                maxWidth: AppContentWidth.form,
                child: InnerPagesAppBar(rightButton: null, title: 'مربی جدید'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: MaxWidthBox(
                    maxWidth: AppContentWidth.form,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.38),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: AppColors.glassBorder,
                              width: 1.2,
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppTextField(
                                  controller: _username,
                                  label: 'نام کاربری',
                                  validator: _required,
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: _email,
                                  label: 'ایمیل',
                                  validator: (v) {
                                    if (_required(v) != null) return 'الزامی';
                                    if (!v!.contains('@')) {
                                      return 'ایمیل معتبر وارد کنید';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: _password,
                                  label: 'رمز عبور',
                                  obscureText: true,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) return 'الزامی';
                                    if (v.length < 8) return 'حداقل ۸ کاراکتر';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                AppTextField(
                                  controller: _confirm,
                                  label: 'تکرار رمز عبور',
                                  obscureText: true,
                                  validator: (v) => v != _password.text
                                      ? 'رمز عبور مطابقت ندارد'
                                      : null,
                                ),
                                const SizedBox(height: 28),
                                AppButton(
                                  text: 'ایجاد مربی',
                                  isLoading: _isSubmitting,
                                  onPressed: _isSubmitting ? null : _submit,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
