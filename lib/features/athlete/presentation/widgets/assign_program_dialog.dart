import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/dialogs/app_dialog.dart';
import 'package:coach_studio/core/widgets/inputs/app_dropdown.dart';
import 'package:coach_studio/core/widgets/inputs/app_text_field.dart';
import 'package:coach_studio/features/workout_programs/domain/entities/workout_program.dart';
import 'package:flutter/material.dart';

class AssignProgramResult {
  final String sourceProgramId;
  final String? title;
  const AssignProgramResult({required this.sourceProgramId, this.title});
}

class AssignProgramDialog extends StatefulWidget {
  final List<WorkoutProgram> programs;
  final bool replacesCurrent;

  const AssignProgramDialog({
    super.key,
    required this.programs,
    required this.replacesCurrent,
  });

  @override
  State<AssignProgramDialog> createState() => _AssignProgramDialogState();
}

class _AssignProgramDialogState extends State<AssignProgramDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  WorkoutProgram? _selected;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    Navigator.of(context).pop(
      AssignProgramResult(
        sourceProgramId: _selected!.id,
        title: title.isEmpty ? null : title,
      ),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اختصاص برنامه',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.replacesCurrent
                  ? 'یک کپی مستقل از برنامه ساخته می‌شود و برنامه‌ی فعلی ورزشکار به سابقه منتقل می‌شود.'
                  : 'یک کپی مستقل از برنامه‌ی انتخابی برای ورزشکار ساخته می‌شود.',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle,
            ),
            const SizedBox(height: 20),
            AppDropdown<WorkoutProgram>(
              label: 'برنامه',
              value: _selected,
              items: widget.programs,
              itemLabel: (p) => p.title,
              validator: (v) => v == null ? 'الزامی' : null,
              onChanged: (v) => setState(() => _selected = v),
            ),
            const SizedBox(height: 14),
            AppTextField(
              controller: _titleController,
              label: 'عنوان نسخه‌ی ورزشکار (اختیاری)',
            ),
            const SizedBox(height: 24),
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
                    text: 'تایید',
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
