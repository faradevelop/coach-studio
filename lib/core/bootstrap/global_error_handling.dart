import 'package:coach_studio/core/di/injection_container.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/monitoring/crash_reporter.dart';
import 'package:flutter/foundation.dart';

/// Shared by both entry points (Coach app / Admin web).
void setupGlobalErrorHandling() {
  FlutterError.onError = (FlutterErrorDetails details) {
    _report('Flutter Error', details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    _report('Platform Error', error, stack);
    return true;
  };
}

void _report(String message, Object error, StackTrace? stack) {
  // Errors thrown before dependency injection is ready must not crash the
  // handler itself.
  if (!sl.isRegistered<AppLogger>()) {
    debugPrint('$message (before DI): $error');
    return;
  }
  sl<AppLogger>().error(message, error: error, stackTrace: stack);
  if (sl.isRegistered<CrashReporter>()) {
    sl<CrashReporter>().recordError(error, stack, fatal: true);
  }
}
