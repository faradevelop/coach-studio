import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_shadows.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/buttons/app_button.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:flutter/material.dart';

/// Generic bottom sheet for picking one or many values of type [T] from a
/// fixed list of options. Selections made inside the sheet live in local
/// widget state and are reported back only via [onApply] — cancelling or
/// dismissing the sheet never mutates the caller's already-applied state.
class MultiSelectBottomSheet<T> extends StatefulWidget {
  final String title;
  final List<T> options;
  final String Function(T) labelBuilder;
  final List<T> initialSelected;
  final bool singleSelect;
  final void Function(List<T> selected) onApply;
  final String confirmText;
  final String cancelText;

  const MultiSelectBottomSheet({
    super.key,
    required this.title,
    required this.options,
    required this.labelBuilder,
    required this.initialSelected,
    required this.onApply,
    this.singleSelect = false,
    this.confirmText = 'تایید',
    this.cancelText = 'لغو',
  });

  static Future<void> show<T>({
    required BuildContext context,
    required String title,
    required List<T> options,
    required String Function(T) labelBuilder,
    required List<T> initialSelected,
    required void Function(List<T> selected) onApply,
    bool singleSelect = false,
    bool requestFocus = true,
    String confirmText = 'تایید',
    String cancelText = 'لغو',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      requestFocus: requestFocus,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiSelectBottomSheet<T>(
        title: title,
        options: options,
        labelBuilder: labelBuilder,
        initialSelected: initialSelected,
        onApply: onApply,
        singleSelect: singleSelect,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }

  @override
  State<MultiSelectBottomSheet<T>> createState() =>
      _MultiSelectBottomSheetState<T>();
}

class _MultiSelectBottomSheetState<T> extends State<MultiSelectBottomSheet<T>> {
  late List<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<T>.from(widget.initialSelected);
  }

  void _toggle(T option) {
    setState(() {
      final alreadySelected = _selected.contains(option);

      if (widget.singleSelect) {
        _selected = alreadySelected ? [] : [option];
        return;
      }

      if (alreadySelected) {
        _selected.remove(option);
      } else {
        _selected.add(option);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Center(
        child: MaxWidthBox(
          maxWidth: AppContentWidth.form,
          alignmentGeometry: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.5),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
                boxShadow: AppShadows.overlay,
              ),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        widget.title,
                        style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
                      ),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.options.map((option) {
                          final isSelected = _selected.contains(option);
                          return _SelectableChip(
                            label: widget.labelBuilder(option),
                            isSelected: isSelected,
                            onTap: () => _toggle(option),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: widget.cancelText,
                            variant: AppButtonVariant.secondary,
                            size: AppButtonSize.compact,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton(
                            text: widget.confirmText,
                            size: AppButtonSize.compact,
                            onPressed: () {
                              widget.onApply(_selected);
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
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

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.secondary : AppColors.outline,
            width: isSelected ? 1.5 : 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.secondaryDark : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
