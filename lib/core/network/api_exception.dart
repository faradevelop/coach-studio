import 'package:coach_studio/core/error/app_exception.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, required this.statusCode, this.errors});

  @override
  String toString() => message;

  /// Maps a Backend error to a user-presentable [AppException].
  /// The Backend's messages are English, so everything except validation
  /// errors (which carry field-specific text) is replaced with Persian.
  static AppException mapApiException(ApiException exception) {
    switch (exception.statusCode) {
      case 401:
        return const UnauthenticatedException(
          'نشست شما منقضی شده است. لطفاً دوباره وارد شوید.',
        );
      case 403:
        return const ForbiddenException(
          'شما اجازه انجام این عملیات را ندارید.',
        );
      case 404:
        return const NotFoundException('مورد درخواستی یافت نشد.');
      case 408:
        return const NetworkException(
          'پاسخی از سرور دریافت نشد. دوباره تلاش کنید.',
        );
      case 422:
        return ValidationException(
          _firstValidationMessage(exception) ?? exception.message,
        );
      case 429:
        return const RateLimitException(
          'تعداد درخواست‌ها بیش از حد مجاز است. کمی بعد دوباره تلاش کنید.',
        );
      default:
        if (exception.statusCode >= 500) {
          return const ServerException(
            'خطایی در سرور رخ داد. لطفاً بعداً دوباره تلاش کنید.',
          );
        }
        return ServerException(exception.message);
    }
  }

  /// Laravel's first field error ("The username has already been taken.").
  static String? _firstValidationMessage(ApiException e) {
    final errors = e.errors;
    if (errors == null || errors.isEmpty) return null;
    final first = errors.values.first;
    if (first is List && first.isNotEmpty) return first.first.toString();
    return null;
  }
}
