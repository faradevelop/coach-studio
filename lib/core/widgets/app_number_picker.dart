import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppNumberPicker extends StatefulWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const AppNumberPicker({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 100,
  });

  @override
  State<AppNumberPicker> createState() => _AppNumberPickerState();
}

class _AppNumberPickerState extends State<AppNumberPicker> {
  late FixedExtentScrollController _scrollController;

  int get _currentValue => widget.value.clamp(widget.min, widget.max);

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(
      initialItem: _currentValue - widget.min,
    );
  }

  @override
  void didUpdateWidget(covariant AppNumberPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value ||
        oldWidget.min != widget.min ||
        oldWidget.max != widget.max) {
      final index = (_currentValue - widget.min).clamp(
        0,
        widget.max - widget.min,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.jumpToItem(index);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = widget.max - widget.min + 1;

    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(
          color: AppColors.charcoal.withValues(alpha: 0.65),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.teal,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppColors.glass,
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.4),
        ),
      ),
      child: SizedBox(
        height: 88,
        child: CupertinoPicker(
          itemExtent: 36,
          diameterRatio: 1.4,
          squeeze: 1.1,
          useMagnifier: true,
          magnification: 1.12,
          scrollController: _scrollController,
          selectionOverlay: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.tealSoft.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.teal.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
          ),
          onSelectedItemChanged: (index) {
            widget.onChanged(widget.min + index);
          },
          children: [
            for (var i = 0; i < itemCount; i++)
              Center(
                child: Text(
                  '${widget.min + i}',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
