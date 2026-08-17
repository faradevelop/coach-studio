import 'package:coach_studio/core/error/app_exception.dart';

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, required this.statusCode, this.errors});

  @override
  String toString() => message;

  static AppException mapApiException(ApiException exception) {
    switch (exception.statusCode) {
      case 404:
        return NotFoundException(exception.message);
      case 422:
        return ValidationException(exception.message);
      case 500:
        return ServerException(exception.message);
      default:
        return ServerException(exception.message);
    }
  }
}
