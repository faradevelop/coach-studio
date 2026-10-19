import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_cubit.dart';
import 'package:coach_studio/features/authentication/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  static String _greeting(int hour) {
    if (hour < 3) return 'سلام، شب بخیر';
    if (hour < 10) return 'سلام، صبح بخیر';
    if (hour < 16) return 'سلام، روز بخیر';
    if (hour < 19) return 'سلام، عصر بخیر';
    return 'سلام، شب بخیر';
  }

  static String _greetingEmoji(int hour) {
    if (hour < 3) return '🌙';
    if (hour < 10) return '🌅';
    if (hour < 16) return '☀️';
    if (hour < 19) return '🌇';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AuthCubit, AuthState, String?>(
      selector: (state) =>
          state is AuthAuthenticated ? state.user.username : null,
      builder: (context, username) {
        final greeting = _greeting(DateTime.now().hour);
        final greetingEmoji = _greetingEmoji(DateTime.now().hour);
        return Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                if (username != null)
                  Row(
                    children: [
                      Text(
                        username,
                        style: AppTextStyles.titleMedium.copyWith(fontSize: 18),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        greetingEmoji,
                        style: AppTextStyles.title.copyWith(fontSize: 14),
                      ),
                    ],
                  ),

                // Text(
                //   'خلاصه‌ای از وضعیت برنامه‌ها و تمرین‌های شما',
                //   style: AppTextStyles.subtitle,
                // ),
              ],
            ),
            Spacer(),
            HugeIcon(
              icon: HugeIcons.strokeRoundedNotification01,
              size: 27,
              color: AppColors.textPrimary,
            ),
          ],
        );
      },
    );
  }
}
