// lib/features/workout_programs/presentation/widgets/athlete_info_form_dialog.dart
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اطلاعات ورزشکار'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'نام و نام خانوادگی',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'الزامی' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'قد (cm)'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'الزامی' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'وزن (kg)'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'الزامی' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('انصراف'),
        ),
        FilledButton(onPressed: _submit, child: const Text('تایید و ساخت PDF')),
      ],
    );
  }
}
