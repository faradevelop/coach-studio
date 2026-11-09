/// Sink for unexpected, unhandled errors. The default is a no-op; plug a
/// real service (e.g. Sentry) by registering another implementation in DI.
abstract interface class CrashReporter {
  void recordError(Object error, StackTrace? stackTrace, {bool fatal = false});
}

class NoopCrashReporter implements CrashReporter {
  const NoopCrashReporter();

  @override
  void recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) {}
}
