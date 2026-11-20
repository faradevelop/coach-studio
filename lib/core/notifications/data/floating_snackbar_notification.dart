import 'package:coach_studio/core/notifications/domain/app_notification.dart';
import 'package:coach_studio/core/notifications/domain/app_notification_message.dart';
import 'package:coach_studio/core/notifications/domain/app_notification_type.dart';
import 'package:coach_studio/core/theme/app_colors.dart';
import 'package:coach_studio/core/theme/app_text_styles.dart';
import 'package:floating_snackbar/floating_snackbar.dart';
import 'package:material_ui/material_ui.dart';

class FloatingSnackbarNotification implements AppNotification {
  FloatingSnackbarNotification({
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    FloatingSnackBar.navigatorKey = navigatorKey;
  }

  @override
  void show(AppNotificationMessage notification) {
    FloatingSnackBar.show(
      null,
      notification.message,
      title: notification.title,
      position: FloatingSnackBarPosition.top,
      type: _mapType(notification.type),
      backgroundColor:
          notification.backgroundColor ?? _defaultColor(notification.type),
      textStyle: AppTextStyles.body.copyWith(
        color: Colors.white,
        decoration: TextDecoration.none,
      ),
      titleStyle: AppTextStyles.titleMedium.copyWith(
        color: Colors.white,
        fontSize: 15,
        decoration: TextDecoration.none,
      ),
      action: _buildAction(notification),
    );
  }

  @override
  void success(
    String message, {
    String? title,
    String? actionLabel,
    AppNotificationAction? onAction,
  }) {
    show(
      AppNotificationMessage(
        message: message,
        type: AppNotificationType.success,
        title: title,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  @override
  void error(
    String message, {
    String? title,
    String? actionLabel,
    AppNotificationAction? onAction,
  }) {
    show(
      AppNotificationMessage(
        message: message,
        type: AppNotificationType.error,
        title: title,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  @override
  void info(
    String message, {
    String? title,
    String? actionLabel,
    AppNotificationAction? onAction,
  }) {
    show(
      AppNotificationMessage(
        message: message,
        type: AppNotificationType.info,
        title: title,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  @override
  void warning(
    String message, {
    String? title,
    String? actionLabel,
    AppNotificationAction? onAction,
  }) {
    show(
      AppNotificationMessage(
        message: message,
        type: AppNotificationType.warning,
        title: title,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }

  FloatingSnackBarType _mapType(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.success:
        return FloatingSnackBarType.success;

      case AppNotificationType.error:
        return FloatingSnackBarType.error;

      case AppNotificationType.info:
        return FloatingSnackBarType.info;

      case AppNotificationType.warning:
        return FloatingSnackBarType.warning;
    }
  }

  FloatingSnackBarAction? _buildAction(AppNotificationMessage notification) {
    if (notification.actionLabel == null || notification.onAction == null) {
      return null;
    }

    return FloatingSnackBarAction(
      label: notification.actionLabel!,
      onPressed: notification.onAction!,
    );
  }

  Color _defaultColor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.success:
        return AppColors.success;

      case AppNotificationType.error:
        return AppColors.error;

      case AppNotificationType.info:
        return AppColors.info;

      case AppNotificationType.warning:
        return AppColors.warning;
    }
  }
}
