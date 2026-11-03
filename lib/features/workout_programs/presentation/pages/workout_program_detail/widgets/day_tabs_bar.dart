import 'dart:ui' show PointerDeviceKind;

import 'package:coach_studio/core/localization/extensions/number_extensions.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/display/app_reorderable.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_cubit.dart';
import 'package:coach_studio/features/workout_programs/presentation/cubit/workout_program_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

/// Horizontal row of day tabs. Pure UI: every action is reported through
/// callbacks; only the "a day operation is in flight" flag is read from
/// [WorkoutProgramCubit] to disable buttons.
class DayTabsBar extends StatelessWidget {
  final List<int> days;
  final int selectedDay;
  final bool isManaging;
  final ValueChanged<int> onDaySelected;
  final VoidCallback onEnterManaging;
  final VoidCallback onExitManaging;
  final VoidCallback onAddDay;
  final ValueChanged<int> onDeleteDay;
  final void Function(int oldIndex, int newIndex) onReorderDay;

  const DayTabsBar({
    super.key,
    required this.days,
    required this.selectedDay,
    required this.isManaging,
    required this.onDaySelected,
    required this.onEnterManaging,
    required this.onExitManaging,
    required this.onAddDay,
    required this.onDeleteDay,
    required this.onReorderDay,
  });

  static final _scrollBehavior = const MaterialScrollBehavior().copyWith(
    dragDevices: {
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.trackpad,
    },
  );

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorkoutProgramCubit, WorkoutProgramState>(
      builder: (context, programState) {
        final isBusy =
            programState is WorkoutProgramLoaded && programState.isSubmitting;

        return ScrollConfiguration(
          behavior: _scrollBehavior,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                isManaging ? _buildReorderableTabs(isBusy) : _buildTabs(),
                const SizedBox(width: 8),
                if (isManaging)
                  Padding(
                    padding: const EdgeInsets.only(right: 6, bottom: 4),
                    child: _DoneManagingButton(onTap: onExitManaging),
                  )
                else
                  _AddDayButton(enabled: !isBusy, onTap: onAddDay),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReorderableTabs(bool isBusy) {
    return AppReorderableRow(
      onReorder: onReorderDay,
      children: [
        for (final day in days)
          Padding(
            key: ValueKey('day-$day'),
            padding: const EdgeInsets.only(left: 4),
            child: DayTab(
              day: day,
              isSelected: day == selectedDay,
              isManaging: true,
              onTap: () => onDaySelected(day),
              // null frees the long-press for the ReorderableRow's own
              // LongPressDraggable instead of re-entering edit mode.
              onLongPress: null,
              onDelete: isBusy ? null : () => onDeleteDay(day),
            ),
          ),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        for (int i = 0; i < days.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          DayTab(
            day: days[i],
            isSelected: days[i] == selectedDay,
            isManaging: false,
            onTap: () => onDaySelected(days[i]),
            onLongPress: onEnterManaging,
            onDelete: null,
          ),
        ],
      ],
    );
  }
}

class DayTab extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isManaging;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;

  const DayTab({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isManaging,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _buildLabel(),
          if (isManaging)
            PositionedDirectional(
              top: -8,
              end: -3,
              child: _DeleteBadge(onTap: onDelete),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.outline,
          width: 1.2,
        ),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: AppTextStyles.caption.copyWith(
          letterSpacing: 0.2,
          fontWeight: FontWeight.w500,
          color: isSelected
              ? AppColors.primary
              : AppColors.textPrimary.withValues(alpha: 0.78),
        ),
        child: Text('روز ${day.persianNumber}'),
      ),
    );
  }
}

class _DeleteBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const _DeleteBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
      ),
    );
  }
}

/// 28px round tappable shell shared by the add / done buttons.
class _RoundActionButton extends StatelessWidget {
  final VoidCallback? onTap;
  final BoxDecoration decoration;
  final Widget child;

  const _RoundActionButton({
    required this.onTap,
    required this.decoration,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: decoration,
        child: child,
      ),
    );
  }
}

class _AddDayButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _AddDayButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? AppColors.accent
        : AppColors.accent.withValues(alpha: 0.4);

    return _RoundActionButton(
      onTap: enabled ? onTap : null,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: color, width: 0.7),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedAdd01,
        size: 18,
        color: color,
      ),
    );
  }
}

class _DoneManagingButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DoneManagingButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _RoundActionButton(
      onTap: onTap,
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
    );
  }
}
