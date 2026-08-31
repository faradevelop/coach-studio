/// Abstract logging interface for the application.
///
/// All logging throughout the application should depend on this abstraction
/// rather than directly depending on the concrete `Logger` package.
/// This keeps business logic decoupled from logging implementation details.
abstract class AppLogger {
  /// Log a debug-level message.
  ///
  /// Use for detailed technical information useful during development.
  void debug(String message, {Object? error, StackTrace? stackTrace});

  /// Log an info-level message.
  ///
  /// Use for important normal application events that users/developers
  /// should be aware of.
  void info(String message, {Object? error, StackTrace? stackTrace});

  /// Log a warning-level message.
  ///
  /// Use for abnormal but recoverable situations.
  void warning(String message, {Object? error, StackTrace? stackTrace});

  /// Log an error-level message.
  ///
  /// Use for exceptions and failed operations.
  void error(String message, {Object? error, StackTrace? stackTrace});
}
