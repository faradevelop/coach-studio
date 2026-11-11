import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/widgets/display/app_glass_surface.dart';
import 'package:coach_studio/core/widgets/responsive/max_width_box.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class ScaffoldWithBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithBottomNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Flat page background (design system `background`).
        const ColoredBox(color: AppColors.background, child: SizedBox.expand()),

        Scaffold(backgroundColor: Colors.transparent, body: navigationShell),

        // Floating glass navbar — the single blurred element in the shell.
        PositionedDirectional(
          start: 12,
          end: 12,
          bottom: 16,
          child: Center(
            child: MaxWidthBox(
              maxWidth: AppContentWidth.bottomNav,
              child: GlassBottomNav(
                currentIndex: navigationShell.currentIndex,
                onTap: (index) {
                  navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  GlassBottomNav({super.key, required this.currentIndex, required this.onTap});

  static const double height = 72;

  // Order MUST match the StatefulShellBranch order in AppRouter.
  final List<_NavItemData> _items = [
    _NavItemData(
      name: 'داشبورد',
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedHome01,
        size: 19,
        color: AppColors.textSecondary,
      ),
      activeIcon: HugeIcon(
        icon: HugeIcons.strokeRoundedHome01,
        size: 20,
        color: AppColors.primary,
      ),
    ),
    _NavItemData(
      name: 'برنامه',
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedTask01,
        size: 19,
        color: AppColors.textSecondary,
      ),
      activeIcon: HugeIcon(
        icon: HugeIcons.strokeRoundedTask01,
        size: 20,
        color: AppColors.primary,
      ),
    ),
    _NavItemData(
      name: 'ورزشکار',
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedGymnastic,
        size: 19,
        color: AppColors.textSecondary,
      ),
      activeIcon: HugeIcon(
        icon: HugeIcons.strokeRoundedGymnastic,
        size: 20,
        color: AppColors.primary,
      ),
    ),
    _NavItemData(
      name: 'تمرین',
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedDumbbell01,
        size: 19,
        color: AppColors.textSecondary,
      ),
      activeIcon: HugeIcon(
        icon: HugeIcons.strokeRoundedDumbbell01,
        size: 20,
        color: AppColors.primary,
      ),
    ),
    _NavItemData(
      name: 'تنظیمات',
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedSettings01,
        size: 17,
        color: AppColors.textSecondary,
      ),
      activeIcon: HugeIcon(
        icon: HugeIcons.strokeRoundedSettings01,
        size: 18,
        color: AppColors.primary,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppGlassSurface(
      blur: true,
      radius: AppRadius.full,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: height,
        child: Row(
          children: List.generate(_items.length, (index) {
            final item = _items[index];
            final selected = index == currentIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      scale: selected ? 1.12 : 1.0,
                      child: selected ? item.activeIcon : item.icon,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.name,
                      style: TextStyle(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final Widget icon;
  final Widget activeIcon;
  final String name;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.name,
  });
}
