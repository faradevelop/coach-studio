import 'dart:ui';
import 'package:coach_studio/core/widgets/app_text_field.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/athlete_info.dart';
import 'package:flutter/material.dart';

class AthleteInfoFormDialog extends StatefulWidget {
  const AthleteInfoFormDialog({super.key});

  @override
  State<AthleteInfoFormDialog> createState() => _AthleteInfoFormDialogState();
}

class _AthleteInfoFormDialogState extends State<AthleteInfoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  static const Color _orange = Color(0xFFFF6B35);
  static const Color _charcoal = Color(0xFF2D2D2D);

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      AthleteInfo(
        fullName: _nameController.text.trim(),
        height: _heightController.text.trim(),
        weight: _weightController.text.trim(),
        date: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
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
                  // آیکون
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _orange.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: _orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // عنوان
                  const Text(
                    'اطلاعات ورزشکار',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: _charcoal,
                    ),
                  ),
                  const SizedBox(height: 22),

                  // فیلدها
                  AppTextField(
                    controller: _nameController,
                    label: 'نام و نام خانوادگی',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'الزامی' : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _heightController,
                    label: 'قد (cm)',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'الزامی' : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _weightController,
                    label: 'وزن (kg)',
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'الزامی' : null,
                  ),
                  const SizedBox(height: 26),

                  // دکمه‌ها
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
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
                                color: _charcoal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _submit,
                          child: Container(
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _orange,
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color: _orange.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Text(
                              ' ساخت PDF',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
