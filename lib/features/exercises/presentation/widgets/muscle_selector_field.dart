import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/widgets/multi_select_bottom_sheet.dart';
import 'package:coach_studio/features/exercises/domain/entities/muscle.dart';
import 'package:flutter/material.dart';

/// Multi-select field for an exercise's target muscles. Shows the current
/// selection as removable chips beneath a field that opens
/// [MultiSelectBottomSheet] for editing. Used by [ExerciseForm] in both
/// create and edit mode.
class MuscleSelectorField extends StatelessWidget {
  final List<Muscle> allMuscles;
  final List<Muscle> selected;
  final ValueChanged<List<Muscle>> onChanged;
  final String? errorText;

  const MuscleSelectorField({
    super.key,
    required this.allMuscles,
    required this.selected,
    required this.onChanged,
    this.errorText,
  });

  void _openPicker(BuildContext context) {
    MultiSelectBottomSheet.show<Muscle>(
      context: context,
      title: 'انتخاب عضلات هدف',
      options: allMuscles,
      labelBuilder: (m) => m.name,
      initialSelected: selected,
      onApply: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _openPicker(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.glass,
              borderRadius: BorderRadius.circular(AppRadius.md + 2),
              border: Border.all(
                color: errorText != null
                    ? AppColors.error
                    : AppColors.glassBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.charcoal.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    selected.isEmpty
                        ? 'عضلات هدف'
                        : 'عضلات هدف (${selected.length})',
                    style: TextStyle(
                      color: AppColors.charcoal.withValues(
                        alpha: selected.isEmpty ? 0.55 : 0.85,
                      ),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selected.map((muscle) {
              return _RemovableMuscleChip(
                label: muscle.name,
                onRemove: () {
                  onChanged(selected.where((m) => m.id != muscle.id).toList());
                },
              );
            }).toList(),
          ),
        ],
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(color: AppColors.error, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _RemovableMuscleChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _RemovableMuscleChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 12, left: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.tealDark,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.tealDark,
            ),
          ),
        ],
      ),
    );
  }
}
