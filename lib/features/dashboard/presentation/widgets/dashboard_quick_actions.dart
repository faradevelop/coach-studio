import 'package:coach_studio/app/routing/app_route_names.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_radius.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:coach_studio/core/widgets/display/app_surface.dart';
import 'package:coach_studio/features/dashboard/presentation/widgets/dashboard_section_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14, 14, 16, 2),
            child: DashboardSectionHeader(
              title: 'دسترسی سریع',
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedZap,
                color: AppColors.primary,
                size: 21,
                strokeWidth: 2,
              ),
            ),
          ),
          Divider(),
          SizedBox(height: 8),
          _QuickActionItem(
            text: 'ساخت برنامه ',
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedTask01,
              color: AppColors.primary,
            ),
            itemVariant: AppColors.primary,
            onPressed: () =>
                context.goNamed(AppRouteNames.createWorkoutProgram),
          ),
          SizedBox(height: 10),
          _QuickActionItem(
            text: 'اضافه کردن ورزشکار',
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedUserMultiple02,
              color: AppColors.accent,
            ),
            itemVariant: AppColors.accent,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color itemVariant;
  final Widget icon;

  const _QuickActionItem({
    required this.text,
    required this.icon,
    this.onPressed,
    required this.itemVariant,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          height: 46,
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: itemVariant.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                padding: EdgeInsets.all(5.5),
                decoration: BoxDecoration(
                  color: itemVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: icon,
              ),
              SizedBox(width: 6),
              Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  color: itemVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
