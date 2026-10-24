import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_shadows.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// Dropdown سفارشی: فیلد + پنل جستجو که کاملاً «زیر» فیلد باز می‌شود.
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.value,
    this.validator,
    this.hint = 'انتخاب کنید',
  });

  @override
  Widget build(BuildContext context) {
    final current = items.contains(value) ? value : null;

    return FormField<T>(
      initialValue: current,
      validator: validator,
      autovalidateMode: validator == null
          ? AutovalidateMode.disabled
          : AutovalidateMode.onUserInteraction,
      builder: (state) {
        return _DropdownField<T>(
          label: label,
          hint: hint,
          items: items,
          itemLabel: itemLabel,
          value: current,
          enabled: onChanged != null,
          errorText: state.errorText,
          onSelected: (item) {
            state.didChange(item);
            onChanged?.call(item);
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Field (فیلد بسته + مدیریت Overlay)
// ─────────────────────────────────────────────────────────────
class _DropdownField<T> extends StatefulWidget {
  final String label;
  final String hint;
  final List<T> items;
  final String Function(T) itemLabel;
  final T? value;
  final bool enabled;
  final String? errorText;
  final ValueChanged<T> onSelected;

  const _DropdownField({
    required this.label,
    required this.hint,
    required this.items,
    required this.itemLabel,
    required this.value,
    required this.enabled,
    required this.errorText,
    required this.onSelected,
  });

  @override
  State<_DropdownField<T>> createState() => _DropdownFieldState<T>();
}

class _DropdownFieldState<T> extends State<_DropdownField<T>> {
  static const double _gap = 6;

  final LayerLink _link = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _entry;

  bool get _isOpen => _entry != null;

  @override
  void didUpdateWidget(covariant _DropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry?.markNeedsBuild();
  }

  @override
  void dispose() {
    _removeEntry();
    super.dispose();
  }

  void _removeEntry() {
    final entry = _entry;
    if (entry == null) return;
    _entry = null;
    entry.remove();
    entry.dispose();
  }

  void _toggle() => _isOpen ? _close() : _open();

  void _open() {
    if (!widget.enabled || _isOpen) return;

    final box = _fieldKey.currentContext!.findRenderObject() as RenderBox;
    final size = box.size;
    final fieldBottom = box.localToGlobal(Offset.zero).dy + size.height;

    final media = MediaQuery.of(context);
    final available =
        media.size.height - media.viewInsets.bottom - fieldBottom - _gap - 12;
    final maxHeight = available.clamp(180.0, 340.0);

    _entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // کلیک بیرون از پنل = بستن
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              // لبه‌ی بالای پنل = لبه‌ی پایین فیلد  → پنل کاملاً زیر فیلد
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(0, _gap),
              child: SizedBox(
                width: size.width,
                child: _DropdownPanel<T>(
                  items: widget.items,
                  itemLabel: widget.itemLabel,
                  selected: widget.value,
                  maxHeight: maxHeight,
                  onSelected: (item) {
                    _close();
                    widget.onSelected(item);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_entry!);
    setState(() {});
  }

  void _close() {
    if (!_isOpen) return;
    _removeEntry();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final selectedLabel = widget.value == null
        ? null
        : widget.itemLabel(widget.value as T).persianNumber;

    final borderColor = hasError
        ? AppColors.error
        : _isOpen
        ? AppColors.secondary
        : AppColors.outline;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label بالای فیلد (مثل تصویر)
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
          child: Text(
            widget.label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary.withValues(alpha: 0.8),
            ),
          ),
        ),
        CompositedTransformTarget(
          link: _link,
          child: GestureDetector(
            key: _fieldKey,
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? _toggle : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: widget.enabled
                    ? AppColors.surface
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.field),
                border: Border.all(
                  color: borderColor,
                  width: _isOpen || hasError ? 1.5 : 1,
                ),
                // boxShadow: _isOpen
                //     ? [
                //         BoxShadow(
                //           color: AppColors.primary.withValues(alpha: 0.12),
                //           spreadRadius: 3,
                //         ),
                //       ]
                //     : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedLabel ?? widget.hint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: selectedLabel == null
                            ? AppColors.textSecondary
                            : (widget.enabled
                                  ? AppColors.textPrimary
                                  : AppColors.textPrimary.withValues(
                                      alpha: 0.5,
                                    )),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _isOpen
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
            child: Text(
              widget.errorText!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Panel (جستجو + لیست)
// ─────────────────────────────────────────────────────────────
class _DropdownPanel<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;
  final T? selected;
  final double maxHeight;
  final ValueChanged<T> onSelected;

  const _DropdownPanel({
    required this.items,
    required this.itemLabel,
    required this.selected,
    required this.maxHeight,
    required this.onSelected,
  });

  @override
  State<_DropdownPanel<T>> createState() => _DropdownPanelState<T>();
}

class _DropdownPanelState<T> extends State<_DropdownPanel<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _filtered {
    final q = _query.trim().englishNumber.toLowerCase();
    if (q.isEmpty) return widget.items;
    return widget.items
        .where(
          (e) => widget.itemLabel(e).englishNumber.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * -6),
          child: child,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.overlay,
        ),
        child: Material(
          color: AppColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: const BorderSide(color: AppColors.outline),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSearch(),
                Flexible(
                  child: filtered.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'موردی یافت نشد',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(8, 2, 8, 10),
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final item = filtered[i];
                            return _OptionTile(
                              label: widget.itemLabel(item).persianNumber,
                              isSelected: item == widget.selected,
                              onTap: () => widget.onSelected(item),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: c, width: w),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: SizedBox(
        height: 44,
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _query = v),
          cursorColor: AppColors.secondary,
          style: AppTextStyles.body.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'جستجو...',
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 22,
              color: AppColors.textSecondary,
            ),
            isDense: true,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: border(AppColors.outline),
            enabledBorder: border(AppColors.outline),
            focusedBorder: border(AppColors.secondary, 1.2),
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isSelected ? AppColors.secondarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            child: Row(
              children: [
                // نقطه‌ی حلقه‌ای کنار هر گزینه
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: 3,
                      color: isSelected
                          ? AppColors.secondary
                          : AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14.5,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.secondaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_rounded,
                    size: 20,
                    color: AppColors.secondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
