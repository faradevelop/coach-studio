import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/localization/formatters/app_number_formatter.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/core/widgets/inputs/app_text_field.dart';
import 'package:coach_studio/core/widgets/navigation/custom_app_bar.dart';
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
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _username = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'الزامی' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _email.text.trim();

    setState(() => _isSubmitting = true);
    final error = await context.read<CoachCubit>().createCoach(
      username: _username.text.trim(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      phone: AppNumberFormatter.toEnglish(_phone.text).trim(),
      email: email.isEmpty ? null : email,
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
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                  child: AppSurface(
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: _firstName,
                            label: 'نام',
                            validator: _required,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _lastName,
                            label: 'نام خانوادگی',
                            validator: _required,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _username,
                            label: 'نام کاربری',
                            validator: _required,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _phone,
                            label: 'شماره موبایل',
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              final value = AppNumberFormatter.toEnglish(
                                v,
                              ).trim();
                              if (value.isEmpty) return 'الزامی';
                              if (value.length > 30 ||
                                  !RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
                                return 'شماره موبایل معتبر نیست';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _email,
                            label: 'ایمیل (اختیاری)',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              final value = v?.trim() ?? '';
                              if (value.isEmpty) return null;
                              return value.contains('@')
                                  ? null
                                  : 'ایمیل معتبر وارد کنید';
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
          ],
        ),
      ),
    );
  }
}
