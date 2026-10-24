import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_shadows.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  static String _greeting(int hour) {
    if (hour < 3) return 'شب بخیر';
    if (hour < 10) return 'صبح بخیر';
    if (hour < 16) return 'روز بخیر';
    if (hour < 19) return 'عصر بخیر';
    return 'شب بخیر';
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _greeting(DateTime.now().hour);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(14, 16, 14, 0),

          child: const _TopBar(),
        ),
        const SizedBox(height: AppSpacing.md),
        _HeroGreeting(greeting: '$greeting،', name: 'پردیس'),
      ],
    );
  }
}

// ── Top bar: brand, notifications, avatar ─────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.primaryGlow,
          ),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedDumbbell01,
            size: 20,
            color: AppColors.onPrimary,
            strokeWidth: 2,
          ),
        ),
        const SizedBox(width: 10),
        Text('Coach Studio', style: AppTextStyles.titleMedium),
        const Spacer(),
        _CircleAction(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedNotification01,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _CircleAction extends StatelessWidget {
  final Widget child;

  const _CircleAction({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.glassHighlight,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outline),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

// ── Greeting + illustration ───────────────────────────────────

class _HeroGreeting extends StatelessWidget {
  final String greeting;
  final String name;

  const _HeroGreeting({required this.greeting, required this.name});

  static const double _height = 200;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = (constraints.maxWidth * 0.42).clamp(130.0, 280.0);
        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              PositionedDirectional(
                end: -imageWidth * 0.08,
                top: 10,
                child: _Blob(
                  size: (imageWidth * 0.8).clamp(150.0, 204.0),
                  gradient: AppColors.accentGradient,
                ),
              ),
              PositionedDirectional(
                end: imageWidth * 0.5 - 10,
                bottom: 6,
                child: _Blob(
                  size: imageWidth * 0.5,
                  gradient: AppColors.secondaryGradient,
                ),
              ),
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                width: imageWidth,
                child: Image.asset(
                  'assets/images/athlete_solid.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              PositionedDirectional(
                start: 0,
                end: imageWidth + 8,
                top: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: AppTextStyles.hero.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(name, style: AppTextStyles.hero),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'خلاصه‌ای از وضعیت برنامه‌ها و تمرین‌های شما',
                        style: AppTextStyles.subtitle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Gradient gradient;

  const _Blob({required this.size, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
    );
  }
}
