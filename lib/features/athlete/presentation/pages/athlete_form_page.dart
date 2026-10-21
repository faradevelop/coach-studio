import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/localization/formatters/app_number_formatter.dart';
import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/core/widgets/feedback/app_error_state.dart';
import 'package:coach_studio/core/widgets/inputs/app_dropdown.dart';
import 'package:coach_studio/core/widgets/inputs/app_number_picker.dart';
import 'package:coach_studio/core/widgets/inputs/app_text_field.dart';
import 'package:coach_studio/core/widgets/navigation/custom_app_bar.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:coach_studio/features/athlete/domain/entities/athlete.dart';
import 'package:coach_studio/features/athlete/domain/enums/gender.dart';
import 'package:coach_studio/features/athlete/domain/repositories/athlete_repository.dart';
import 'package:coach_studio/features/athlete/presentation/cubit/athlete_cubit.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_goal.dart';
import 'package:coach_studio/features/workout_programs/domain/enums/program_level.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shamsi_date/shamsi_date.dart';

class AthleteFormPage extends StatefulWidget {
  final String? athleteId; // present -> edit mode
  final Athlete? seedAthlete;

  const AthleteFormPage({super.key, this.athleteId, this.seedAthlete});

  @override
  State<AthleteFormPage> createState() => _AthleteFormPageState();
}

class _AthleteFormPageState extends State<AthleteFormPage> {
  Future<Athlete>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    if (widget.athleteId != null && widget.seedAthlete == null) {
      _future = sl<AthleteRepository>().getAthlete(widget.athleteId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final future = _future;
    if (future == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: _AthleteForm(initial: widget.seedAthlete),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<Athlete>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: AppColors.primary,
                size: 40,
              ),
            );
          }
          if (snap.hasError || snap.data == null) {
            return AppErrorState(onRetry: () => setState(_load));
          }
          return _AthleteForm(initial: snap.data);
        },
      ),
    );
  }
}

class _AthleteForm extends StatefulWidget {
  final Athlete? initial;
  const _AthleteForm({this.initial});

  @override
  State<_AthleteForm> createState() => _AthleteFormState();
}

class _AthleteFormState extends State<_AthleteForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _injuries;
  late final TextEditingController _limitations;
  late final TextEditingController _notes;

  Gender? _gender;
  ProgramGoal? _goal;
  ProgramLevel? _level;
  bool _hasDob = false;
  late int _dobYear;
  late int _dobMonth;
  late int _dobDay;
  bool _isSubmitting = false;

  bool get _isEdit => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final a = widget.initial;
    _firstName = TextEditingController(text: a?.firstName ?? '');
    _lastName = TextEditingController(text: a?.lastName ?? '');
    _phone = TextEditingController(text: a?.phone ?? '');
    _email = TextEditingController(text: a?.email ?? '');
    _height = TextEditingController(text: a?.heightCm?.toString() ?? '');
    _weight = TextEditingController(text: _formatWeight(a?.weightKg));
    _injuries = TextEditingController(text: a?.injuries ?? '');
    _limitations = TextEditingController(text: a?.physicalLimitations ?? '');
    _notes = TextEditingController(text: a?.coachNotes ?? '');
    _gender = a?.gender;
    _goal = a?.fitnessGoal;
    _level = a?.experienceLevel;

    final dob = a?.dateOfBirth;
    if (dob != null) {
      final j = Jalali.fromDateTime(dob);
      _hasDob = true;
      _dobYear = j.year;
      _dobMonth = j.month;
      _dobDay = j.day;
    } else {
      _dobYear = Jalali.now().year - 25;
      _dobMonth = 1;
      _dobDay = 1;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _firstName,
      _lastName,
      _phone,
      _email,
      _height,
      _weight,
      _injuries,
      _limitations,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _formatWeight(double? w) {
    if (w == null) return '';
    return w == w.roundToDouble() ? w.toInt().toString() : w.toString();
  }

  String _en(TextEditingController c) =>
      AppNumberFormatter.toEnglish(c.text).trim();

  String? _blankToNull(String v) => v.isEmpty ? null : v;

  DateTime? _buildDob() {
    if (!_hasDob) return null;
    final maxDay = Jalali(_dobYear, _dobMonth, 1).monthLength;
    final day = _dobDay.clamp(1, maxDay);
    return Jalali(_dobYear, _dobMonth, day).toDateTime();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'الزامی' : null;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final dob = _buildDob();
    if (dob != null && dob.isAfter(DateTime.now())) {
      sl<AppNotification>().error('تاریخ تولد نمی‌تواند در آینده باشد.');
      return;
    }

    final old = widget.initial;
    final athlete = Athlete(
      id: old?.id ?? '',
      coachId: old?.coachId ?? '',
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      gender: _gender,
      dateOfBirth: dob,
      phone: _blankToNull(_en(_phone)),
      email: _blankToNull(_email.text.trim()),
      heightCm: int.tryParse(_en(_height)),
      weightKg: double.tryParse(_en(_weight).replaceAll(RegExp('[٫,]'), '.')),
      fitnessGoal: _goal,
      experienceLevel: _level,
      injuries: _blankToNull(_injuries.text.trim()),
      physicalLimitations: _blankToNull(_limitations.text.trim()),
      coachNotes: _blankToNull(_notes.text.trim()),
      isArchived: old?.isArchived ?? false,
    );

    setState(() => _isSubmitting = true);
    final cubit = context.read<AthleteCubit>();
    final error = _isEdit
        ? await cubit.updateAthlete(athlete)
        : await cubit.createAthlete(athlete);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      sl<AppNotification>().error(error);
      return;
    }
    sl<AppNotification>().success(
      _isEdit ? 'ورزشکار با موفقیت ویرایش شد.' : 'ورزشکار با موفقیت اضافه شد.',
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          MaxWidthBox(
            maxWidth: AppContentWidth.form,
            child: InnerPagesAppBar(
              rightButton: const SizedBox(width: 40),
              title: _isEdit ? 'ویرایش ورزشکار' : 'ایجاد ورزشکار',
            ),
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
                        AppDropdown<Gender>(
                          label: 'جنسیت',
                          value: _gender,
                          items: Gender.values,
                          itemLabel: (g) => g.label,
                          onChanged: (v) => setState(() => _gender = v),
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('تاریخ تولد', style: AppTextStyles.label),
                          value: _hasDob,
                          activeTrackColor: AppColors.secondary,
                          onChanged: (v) => setState(() => _hasDob = v),
                        ),
                        if (_hasDob) ...[
                          Row(
                            children: [
                              Expanded(
                                child: AppNumberPicker(
                                  label: 'سال',
                                  value: _dobYear,
                                  min: 1300,
                                  max: Jalali.now().year,
                                  onChanged: (v) => _dobYear = v,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppNumberPicker(
                                  label: 'ماه',
                                  value: _dobMonth,
                                  min: 1,
                                  max: 12,
                                  onChanged: (v) => _dobMonth = v,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppNumberPicker(
                                  label: 'روز',
                                  value: _dobDay,
                                  min: 1,
                                  max: 31,
                                  onChanged: (v) => _dobDay = v,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _phone,
                          label: 'شماره تماس',
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            final value = AppNumberFormatter.toEnglish(
                              v,
                            ).trim();
                            if (value.isEmpty) return null;
                            if (value.length > 30 ||
                                !RegExp(r'^[0-9+\-\s()]+$').hasMatch(value)) {
                              return 'شماره تماس معتبر نیست';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _email,
                          label: 'ایمیل',
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
                          controller: _height,
                          label: 'قد (cm)',
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final value = AppNumberFormatter.toEnglish(
                              v,
                            ).trim();
                            if (value.isEmpty) return null;
                            final n = int.tryParse(value);
                            if (n == null || n < 50 || n > 300) {
                              return 'عددی بین ۵۰ تا ۳۰۰ وارد کنید';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _weight,
                          label: 'وزن (kg)',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            final value = AppNumberFormatter.toEnglish(
                              v,
                            ).trim().replaceAll(RegExp('[٫,]'), '.');
                            if (value.isEmpty) return null;
                            final n = double.tryParse(value);
                            if (n == null || n < 20 || n > 500) {
                              return 'عددی بین ۲۰ تا ۵۰۰ وارد کنید';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppDropdown<ProgramGoal>(
                          label: 'هدف',
                          value: _goal,
                          items: ProgramGoal.values,
                          itemLabel: (g) => g.label,
                          onChanged: (v) => setState(() => _goal = v),
                        ),
                        const SizedBox(height: 16),
                        AppDropdown<ProgramLevel>(
                          label: 'سطح تجربه',
                          value: _level,
                          items: ProgramLevel.values,
                          itemLabel: (l) => l.label,
                          onChanged: (v) => setState(() => _level = v),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _injuries,
                          label: 'آسیب‌دیدگی‌ها',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _limitations,
                          label: 'محدودیت‌های جسمی',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _notes,
                          label: 'یادداشت مربی',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        AppButton(
                          text: _isEdit ? 'ویرایش' : 'تایید',
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
    );
  }
}
