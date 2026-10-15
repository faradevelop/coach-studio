import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:flutter/foundation.dart';

/// Shared by both entry points (Coach app / Admin web).
void setupGlobalErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    sl<AppLogger>().error(
      'Flutter Error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    sl<AppLogger>().error('Platform Error', error: error, stackTrace: stack);
    return true;
  };
}
