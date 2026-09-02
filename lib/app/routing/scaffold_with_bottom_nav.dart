import 'dart:ui';

import 'package:coach_studio/core/theme/app_colors.dart';
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
        // Background — uses theme tokens
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
              colors: AppColors.bgColors,
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: navigationShell,
          bottomNavigationBar: null, // custom glass bottom nav below
        ),

        // Floating Glass Navbar
        PositionedDirectional(
          start: 12,
          end: 12,
          bottom: 16,
          child: Center(
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
        const SizedBox(height: 6),
      ],
    );
  }
}

class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  GlassBottomNav({super.key, required this.currentIndex, required this.onTap});

  static const double height = 72;

  final List<_NavItemData> _items = [
    _NavItemData(
      name: 'برنامه',
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedTask01,
        size: 19,
        color: AppColors.charcoal,
      ),
      activeIcon: HugeIcon(
        icon: HugeIcons.strokeRoundedTask01,
        size: 20,
        color: AppColors.orange,
      ),
    ),
    _NavItemData(
      name: 'تمرین',
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedDumbbell01,
        size: 19,
        color: AppColors.charcoal,
      ),
      activeIcon: HugeIcon(
        icon: HugeIcons.strokeRoundedDumbbell01,
        size: 20,
        color: AppColors.orange,
      ),
    ),
    _NavItemData(
      name: 'تنظیمات',
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedSettings01,
        size: 17,
        color: AppColors.charcoal,
      ),
      activeIcon: HugeIcon(
        icon: HugeIcons.strokeRoundedSettings01,
        size: 18,
        color: AppColors.orange,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(100)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            border: Border(
              top: BorderSide(color: AppColors.glassBorder, width: 1.2),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.0),
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.45),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
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
                              ? AppColors.orange
                              : AppColors.charcoal,
                          fontSize: 10,
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
