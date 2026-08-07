import 'dart:ui';

import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppButton extends StatelessWidget {
  final String text;

  final VoidCallback? onPressed;

  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: ButtonStyle(
          backgroundColor: onPressed == null
              ? WidgetStatePropertyAll(AppColors.grey)
              : WidgetStatePropertyAll(AppColors.orange),
        ),
        child: isLoading
            ? SizedBox(
                width: 30,
                height: 34,
                child: LoadingAnimationWidget.waveDots(
                  color: AppColors.charcoal,
                  size: 24,
                ),
              )
            : Text(text),
      ),
    );
  }
}

class MiniButton extends StatelessWidget {
  final Color color;
  final Widget icon;
  final VoidCallback onPressed;
  const MiniButton({
    super.key,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            width: 40,
            height: 25,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.55),
                width: 1.2,
              ),
            ),
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}

class GlassyBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const GlassyBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
        ),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.charcoal,
          ),
        ),
      ),
    );
  }
}
