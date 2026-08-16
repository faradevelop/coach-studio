import 'package:coach_studio/core/notifications/domain/app_notification_type.dart';

typedef AppNotificationAction = void Function();

class AppNotificationMessage {
  final String message;
  final String? title;
  final AppNotificationType type;
  final String? actionLabel;
  final AppNotificationAction? onAction;

  const AppNotificationMessage({
    required this.message,
    required this.type,
    this.title,
    this.actionLabel,
    this.onAction,
  }) : assert(
         (actionLabel == null && onAction == null) ||
             (actionLabel != null && onAction != null),
         'actionLabel and onAction must be provided together.',
       );
}
