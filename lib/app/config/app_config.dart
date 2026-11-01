abstract final class AppConfig {
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String _developmentApiUrl = 'http://127.0.0.1:8000/api/v1';

  static const String _productionApiUrl = 'https://api.faracodes.ir/api/v1';

  static bool get isProduction => environment == 'production';

  static bool get isDevelopment => environment == 'development';

  static const String _customApiUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    if (_customApiUrl.isNotEmpty) {
      return _customApiUrl;
    }

    return isProduction ? _productionApiUrl : _developmentApiUrl;
  }
}
