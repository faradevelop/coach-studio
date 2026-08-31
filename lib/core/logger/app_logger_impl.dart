import 'package:logger/logger.dart' as pkg_logger;
import 'app_logger.dart';

/// Production implementation of [AppLogger] using the `logger` package.
///
/// Configured for clear console output during development, with appropriate
/// formatting, timestamps, and colors to make debugging easy.
class AppLoggerImpl implements AppLogger {
  late final pkg_logger.Logger _logger;

  AppLoggerImpl() {
    _logger = pkg_logger.Logger(
      filter: _ProductionFilter(),
      printer: _PrettyPrinter(),
      level: pkg_logger.Level.debug,
    );
  }

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  @override
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

/// Filter for production logging — logs all levels by default.
class _ProductionFilter extends pkg_logger.LogFilter {
  @override
  bool shouldLog(pkg_logger.LogEvent event) {
    return true;
  }
}

/// Custom printer for clean, readable console output.
class _PrettyPrinter extends pkg_logger.PrettyPrinter {
  _PrettyPrinter()
    : super(
        methodCount: 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: pkg_logger.DateTimeFormat.onlyTimeAndSinceStart,
      );
}
