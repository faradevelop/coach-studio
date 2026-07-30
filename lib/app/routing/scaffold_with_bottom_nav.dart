// lib/app/routing/scaffold_with_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared Scaffold for the two main tabs (Exercises, Programs).
///
/// This widget only wraps the main pages (the index route of each branch).
/// Internal pages (Add/Edit/Create/Detail/...) are pushed onto the root Navigator
/// and do not include this Scaffold, so the BottomNav is not displayed on them.
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
                  color: Color(
                    0xFFFF9A5A,
                  ), //const Color(0xFFFFB74D).withOpacity(0.70),
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

          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,

            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                // When tapping the currently active tab again, navigate back to the branch's initial route.
                // (Standard Instagram behavior: the active tab resets its navigation stack to the root.)
                initialLocation: index == navigationShell.currentIndex,
              );
            },

            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.fitness_center_outlined),
                selectedIcon: Icon(Icons.fitness_center),
                label: 'Exercises',
              ),

              NavigationDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt),
                label: 'Programs',
              ),

              // Future tabs, such as Settings, will be added here.
            ],
          ),
        ),
      ],
    );
  }
}
