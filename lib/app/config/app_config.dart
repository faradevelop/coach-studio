import 'package:flutter/foundation.dart' show kReleaseMode;

abstract final class AppConfig {
  static const String _envDefine = String.fromEnvironment('APP_ENV');

  /// Release builds default to production even if `--dart-define=APP_ENV`
  /// was forgotten; debug/profile builds default to development.
  static const String environment = _envDefine != ''
      ? _envDefine
      : (kReleaseMode ? 'production' : 'development');

  static const String _developmentApiUrl = 'http://127.0.0.1:8000/api/v1';

  static const String _productionApiUrl = 'https://api.faracodes.ir/api/v1';

  static bool get isProduction => environment == 'production';

  static bool get isDevelopment => environment == 'development';

  static const String _customApiUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    final url = _customApiUrl.isNotEmpty
        ? _customApiUrl
        : (isProduction ? _productionApiUrl : _developmentApiUrl);

    // Not an assert: asserts are stripped from release builds.
    if (kReleaseMode && !url.startsWith('https://')) {
      throw StateError(
        'Release builds must use an HTTPS API URL (resolved: $url). '
        'Pass --dart-define=API_BASE_URL=https://... or APP_ENV=production.',
      );
    }
    return url;
  }

  /// Call once at startup so a bad configuration fails immediately and
  /// visibly instead of on the first request.
  static void validate() => apiBaseUrl;
}
