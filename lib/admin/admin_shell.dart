import 'package:coach_studio/core/theme/app_breakpoints.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/responsive/responsive_context.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/authentication/presentation/widgets/logout_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

/// Admin layout: side rail on tablet/desktop (extended on desktop),
/// bottom bar on narrow screens. Two destinations: Exercises, Coaches.
class AdminShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AdminShell({super.key, required this.navigationShell});

  void _select(int index) => navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutConfirmationDialog(),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthCubit>().logout();
    }
  }

  Widget _icon(dynamic icon, Color color) =>
      HugeIcon(icon: icon, size: 22, color: color);

  @override
  Widget build(BuildContext context) {
    final index = navigationShell.currentIndex;
    final isMobile = context.isMobile;
    final extended = MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: isMobile
          ? NavigationBar(
              backgroundColor: AppColors.cream,
              indicatorColor: AppColors.orange.withValues(alpha: 0.15),
              selectedIndex: index,
              // The 3rd item is a logout action, not a branch.
              onDestinationSelected: (i) =>
                  i == 2 ? _logout(context) : _select(i),
              destinations: [
                NavigationDestination(
                  icon: _icon(
                    HugeIcons.strokeRoundedDumbbell01,
                    AppColors.charcoal,
                  ),
                  selectedIcon: _icon(
                    HugeIcons.strokeRoundedDumbbell01,
                    AppColors.orange,
                  ),
                  label: 'تمرین‌ها',
                ),
                NavigationDestination(
                  icon: _icon(
                    HugeIcons.strokeRoundedUserAccount,
                    AppColors.charcoal,
                  ),
                  selectedIcon: _icon(
                    HugeIcons.strokeRoundedUserAccount,
                    AppColors.orange,
                  ),
                  label: 'مربی‌ها',
                ),
                NavigationDestination(
                  icon: _icon(
                    HugeIcons.strokeRoundedLogoutCircle02,
                    AppColors.charcoal,
                  ),
                  label: 'خروج',
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            NavigationRail(
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              extended: extended,
              minExtendedWidth: 190,
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              indicatorColor: AppColors.orange.withValues(alpha: 0.15),
              selectedIndex: index,
              onDestinationSelected: _select,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Coach Studio',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.orange,
                  ),
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      tooltip: 'خروج از حساب',
                      onPressed: () => _logout(context),
                      icon: _icon(
                        HugeIcons.strokeRoundedLogoutCircle02,
                        AppColors.charcoal,
                      ),
                    ),
                  ),
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: _icon(
                    HugeIcons.strokeRoundedDumbbell01,
                    AppColors.charcoal,
                  ),
                  selectedIcon: _icon(
                    HugeIcons.strokeRoundedDumbbell01,
                    AppColors.orange,
                  ),
                  label: const Text('تمرین‌ها'),
                ),
                NavigationRailDestination(
                  icon: _icon(
                    HugeIcons.strokeRoundedUserAccount,
                    AppColors.charcoal,
                  ),
                  selectedIcon: _icon(
                    HugeIcons.strokeRoundedUserAccount,
                    AppColors.orange,
                  ),
                  label: const Text('مربی‌ها'),
                ),
              ],
            ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
