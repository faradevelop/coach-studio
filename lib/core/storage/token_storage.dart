import 'package:shared_preferences/shared_preferences.dart';

/// Persists the Sanctum bearer token across app restarts, including
/// Flutter Web (where `shared_preferences` is backed by `localStorage`,
/// so the session survives a page refresh).
///
/// The token is cached in memory after [init] so [ApiClient] can read it
/// synchronously on every request without an async call per request.
class TokenStorage {
  static const _tokenKey = 'auth_token';

  String? _token;

  /// The current in-memory token, or null if there is none / [init] has
  /// not completed yet.
  String? get token => _token;

  /// Loads the persisted token (if any) into memory. Must be awaited once
  /// during app startup, before the router or any authenticated request
  /// runs — see `main.dart`.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
