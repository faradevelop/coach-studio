import 'app_notification_message.dart';

abstract interface class AppNotification {
  void show(AppNotificationMessage notification);

  void success(
    String message, {
    String? title,
    String? actionLabel,
    AppNotificationAction? onAction,
  });

  void error(
    String message, {
    String? title,
    String? actionLabel,
    AppNotificationAction? onAction,
  });

  void info(
    String message, {
    String? title,
    String? actionLabel,
    AppNotificationAction? onAction,
  });

  void warning(
    String message, {
    String? title,
    String? actionLabel,
    AppNotificationAction? onAction,
  });
}
