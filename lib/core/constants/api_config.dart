import 'package:coach_studio/app/config/app_config.dart';

class ApiConfig {
  // Release builds default to production automatically.
  // flutter build web --release            (production by default)
  // flutter run -d chrome                  (development by default)
  // Override with: --dart-define=APP_ENV=development / --dart-define=API_BASE_URL=...
  static String get baseUrl => AppConfig.apiBaseUrl;
}
