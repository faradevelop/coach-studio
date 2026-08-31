import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/core/storage/token_storage.dart';

/// Thin HTTP wrapper responsible for:
/// - sending requests with JSON headers (+ Authorization: Bearer <token>
///   when a session is active)
/// - unwrapping the backend's standard envelope: { success, message, data|errors }
/// - throwing ApiException on failure so callers can handle it uniformly
/// - reporting 401 responses via [onUnauthorized] so the app can clear the
///   local session and redirect to login
class ApiClient {
  final String baseUrl;
  final http.Client _client;
  final TokenStorage tokenStorage;
  final AppLogger _logger;

  /// Invoked whenever ANY request comes back with 401 Unauthorized. Wired
  /// up in `injection_container.dart` once `AuthCubit` exists, to avoid a
  /// circular dependency between the network layer and the auth feature.
  void Function()? onUnauthorized;

  ApiClient({
    required this.baseUrl,
    required this.tokenStorage,
    required AppLogger logger,
    http.Client? client,
  }) : _logger = logger,
       _client = client ?? http.Client();

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = tokenStorage.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<dynamic> get(String path) async {
    _logger.debug('API → GET $path');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      final duration = stopwatch.elapsedMilliseconds;
      final result = _unwrap(response);

      _logger.info('API ← ${response.statusCode} GET $path ($duration ms)');
      return result;
    } catch (e) {
      final duration = stopwatch.elapsedMilliseconds;
      if (e is ApiException) {
        _logger.error(
          'API ← ${e.statusCode} GET $path ($duration ms)',
          error: e.message,
        );
      } else {
        _logger.error('API GET $path failed ($duration ms)', error: e);
      }
      rethrow;
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    _logger.debug('API → POST $path');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      final duration = stopwatch.elapsedMilliseconds;
      final result = _unwrap(response);

      _logger.info('API ← ${response.statusCode} POST $path ($duration ms)');
      return result;
    } catch (e) {
      final duration = stopwatch.elapsedMilliseconds;
      if (e is ApiException) {
        _logger.error(
          'API ← ${e.statusCode} POST $path ($duration ms)',
          error: e.message,
        );
      } else {
        _logger.error('API POST $path failed ($duration ms)', error: e);
      }
      rethrow;
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    _logger.debug('API → PUT $path');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      final duration = stopwatch.elapsedMilliseconds;
      final result = _unwrap(response);

      _logger.info('API ← ${response.statusCode} PUT $path ($duration ms)');
      return result;
    } catch (e) {
      final duration = stopwatch.elapsedMilliseconds;
      if (e is ApiException) {
        _logger.error(
          'API ← ${e.statusCode} PUT $path ($duration ms)',
          error: e.message,
        );
      } else {
        _logger.error('API PUT $path failed ($duration ms)', error: e);
      }
      rethrow;
    }
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    _logger.debug('API → PATCH $path');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
        body: jsonEncode(body),
      );
      final duration = stopwatch.elapsedMilliseconds;
      final result = _unwrap(response);

      _logger.info('API ← ${response.statusCode} PATCH $path ($duration ms)');
      return result;
    } catch (e) {
      final duration = stopwatch.elapsedMilliseconds;
      if (e is ApiException) {
        _logger.error(
          'API ← ${e.statusCode} PATCH $path ($duration ms)',
          error: e.message,
        );
      } else {
        _logger.error('API PATCH $path failed ($duration ms)', error: e);
      }
      rethrow;
    }
  }

  Future<dynamic> delete(String path) async {
    _logger.debug('API → DELETE $path');
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$path'),
        headers: _headers,
      );
      final duration = stopwatch.elapsedMilliseconds;
      final result = _unwrap(response);

      _logger.info('API ← ${response.statusCode} DELETE $path ($duration ms)');
      return result;
    } catch (e) {
      final duration = stopwatch.elapsedMilliseconds;
      if (e is ApiException) {
        _logger.error(
          'API ← ${e.statusCode} DELETE $path ($duration ms)',
          error: e.message,
        );
      } else {
        _logger.error('API DELETE $path failed ($duration ms)', error: e);
      }
      rethrow;
    }
  }

  dynamic _unwrap(http.Response response) {
    final Map<String, dynamic> decoded =
        jsonDecode(response.body) as Map<String, dynamic>;
    final bool success = decoded['success'] as bool? ?? false;

    if (response.statusCode >= 200 && response.statusCode < 300 && success) {
      return decoded['data'];
    }

    if (response.statusCode == 401) {
      _logger.warning('API: Unauthorized (401) — session may be invalid');
      onUnauthorized?.call();
    }

    throw ApiException(
      message: decoded['message'] as String? ?? 'Unexpected error',
      statusCode: response.statusCode,
      errors: decoded['errors'] as Map<String, dynamic>?,
    );
  }
}
