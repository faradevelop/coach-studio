import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Shown while `AuthCubit` restores the session on app startup (and
/// briefly during Web page refreshes), so no protected screen ever
/// flashes before we know whether the user is authenticated.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.bgColors,
            stops: AppColors.bgStops,
          ),
        ),
        child: Center(
          child: LoadingAnimationWidget.hexagonDots(
            color: AppColors.orange,
            size: 46,
          ),
        ),
      ),
    );
  }
}
