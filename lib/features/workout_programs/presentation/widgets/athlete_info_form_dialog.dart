import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/dialogs/app_dialog.dart';
import 'package:coach_studio/core/widgets/inputs/app_text_field.dart';
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

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'الزامی' : null;

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
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'اطلاعات ورزشکار',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 22),
            AppTextField(
              controller: _nameController,
              label: 'نام و نام خانوادگی',
              validator: _required,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _heightController,
              label: 'قد (cm)',
              validator: _required,
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _weightController,
              label: 'وزن (kg)',
              validator: _required,
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'انصراف',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.compact,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    text: 'ساخت PDF',
                    size: AppButtonSize.compact,
                    onPressed: _submit,
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
