class ApiConfig {
  // NOTE ON PLATFORM-SPECIFIC HOSTS:
  // - iOS Simulator / Desktop / Web (same machine as `php artisan serve`): 127.0.0.1 works as-is.
  // - Android Emulator: 127.0.0.1 refers to the emulator itself, NOT your host machine.
  //   Use 10.0.2.2 instead: 'http://10.0.2.2:8000/api/v1'
  // - Physical device: use your machine's LAN IP, e.g. 'http://192.168.1.50:8000/api/v1'
  static const String baseUrl = 'https://api.faracodes.ir/api/v1';
}
