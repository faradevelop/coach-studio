import 'dart:ui';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithBottomNav extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithBottomNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8F4EE), Color(0xFFF5F0E8), Color(0xFFF2ECE5)],
            ),
          ),
        ),

        // Glow
        Positioned(
          top: -80,
          right: -50,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9A5A).withOpacity(0.55),
                  blurRadius: 140,
                  spreadRadius: 40,
                ),
              ],
            ),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: navigationShell,
          bottomNavigationBar: null, // use custom bottom nav bar instead
        ),
        // Floating Glass Navbar
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
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
      name: 'Program',
      icon: FaIcon(FontAwesomeIcons.list, size: 20, color: AppColors.charcoal),
      activeIcon: FaIcon(
        FontAwesomeIcons.list,
        size: 22,
        color: AppColors.orange,
      ),
    ),
    _NavItemData(
      name: 'Exercise',
      icon: FaIcon(
        FontAwesomeIcons.dumbbell,
        size: 20,
        color: AppColors.charcoal,
      ),
      activeIcon: FaIcon(
        FontAwesomeIcons.dumbbell,
        size: 22,
        color: AppColors.orange,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.55),
                width: 1.2,
              ),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.45),
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
                      SizedBox(height: 6),
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
