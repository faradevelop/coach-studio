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
      backgroundColor: AppColors.background,
      body: Center(
        child: LoadingAnimationWidget.twistingDots(
          leftDotColor: AppColors.primary,
          rightDotColor: AppColors.secondary,
          size: 46,
        ),
      ),
    );
  }
}
