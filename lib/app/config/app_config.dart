import 'package:flutter/foundation.dart'
    show kReleaseMode, kIsWeb, defaultTargetPlatform, TargetPlatform;

abstract final class AppConfig {
  static const String _envDefine = String.fromEnvironment('APP_ENV');

  static const String environment = _envDefine != ''
      ? _envDefine
      : (kReleaseMode ? 'production' : 'development');

  static const String _productionApiUrl = 'https://api.faracodes.ir/api/v1';

  static const String _customApiUrl = String.fromEnvironment('API_BASE_URL');

  static String get _developmentApiUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000/api/v1';

      case TargetPlatform.iOS:
        return 'http://127.0.0.1:8000/api/v1';

      default:
        return 'http://127.0.0.1:8000/api/v1';
    }
  }

  static bool get isProduction => environment == 'production';

  static bool get isDevelopment => environment == 'development';

  static String get apiBaseUrl {
    final url = _customApiUrl.isNotEmpty
        ? _customApiUrl
        : (isProduction ? _productionApiUrl : _developmentApiUrl);

    if (kReleaseMode && !url.startsWith('https://')) {
      throw StateError(
        'Release builds must use an HTTPS API URL '
        '(resolved: $url). '
        'Pass --dart-define=API_BASE_URL=https://... '
        'or APP_ENV=production.',
      );
    }

    return url;
  }

  static void validate() => apiBaseUrl;
}
