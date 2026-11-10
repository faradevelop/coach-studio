import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.activeColor,
    this.backgroundColor,
    this.height = 44,
  }) : assert(tabs.length == 3);

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color? activeColor;
  final Color? backgroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.zero,
      height: height,
      //padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.outline.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;
          final isRtl = Directionality.of(context) == TextDirection.rtl;
          final offset = tabWidth * selectedIndex;

          return Stack(
            children: [
              /// Moving active capsule
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                right: isRtl ? offset : null,
                left: isRtl ? null : offset,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: activeColor ?? AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      width: 0.5,
                      color: activeColor ?? AppColors.outline,
                    ),
                  ),
                ),
              ),

              /// Tabs
              Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = selectedIndex == index;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTabSelected(index),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeOut,
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.accentDark
                                : AppColors.textSecondary,
                          ),
                          child: Text(
                            tabs[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
