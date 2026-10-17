import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_spacing.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  static String _greeting(int hour) {
    if (hour < 5) return 'سلام';
    if (hour < 11) return 'صبح بخیر';
    if (hour < 17) return 'روز بخیر';
    if (hour < 19) return 'عصر بخیر';
    return 'سلام';
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthCubit, AuthState, String?>(
      selector: (state) =>
          state is AuthAuthenticated ? state.user.username : null,
      builder: (context, username) {
        final greeting = _greeting(DateTime.now().hour);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'داشبورد',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              username == null ? greeting : '$greeting، $username',
              style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'خلاصه‌ای از وضعیت برنامه‌ها و تمرین‌های شما',
              style: AppTextStyles.subtitle,
            ),
          ],
        );
      },
    );
  }
}
