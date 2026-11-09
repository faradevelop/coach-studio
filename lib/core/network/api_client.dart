import 'dart:async';
import 'dart:convert';

import 'package:coach_studio/core/error/app_exception.dart';
import 'package:coach_studio/core/logger/app_logger.dart';
import 'package:coach_studio/core/network/api_exception.dart';
import 'package:coach_studio/core/storage/token_storage.dart';
import 'package:http/http.dart' as http;

/// Thin HTTP wrapper responsible for:
/// - sending requests with JSON headers (+ Authorization: Bearer `<token>`
///   when a session is active)
/// - enforcing a timeout and mapping connectivity failures to
///   [NetworkException] (GET requests are retried once)
/// - unwrapping the backend's standard envelope: { success, message, data|errors }
/// - throwing ApiException on failure so callers can handle it uniformly
/// - reporting 401 responses via [onUnauthorized] so the app can clear the
///   local session and redirect to login
class ApiClient {
  final Duration _requestTimeout;
  final Duration _retryWait;

  static const String _timeoutMessage =
      'پاسخی از سرور دریافت نشد. اتصال اینترنت خود را بررسی کنید.';
  static const String _offlineMessage =
      'اتصال به سرور برقرار نشد. اتصال اینترنت خود را بررسی کنید.';
  static const String _invalidResponseMessage =
      'پاسخ نامعتبر از سرور دریافت شد. لطفاً بعداً دوباره تلاش کنید.';

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
    required this._logger,
    http.Client? client,
    this._requestTimeout = const Duration(seconds: 20),
    Duration retryDelay = const Duration(milliseconds: 600),
  }) : _client = client ?? http.Client(),
       _retryWait = retryDelay;

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

  // Only idempotent reads are retried; a retried POST could create twice.
  Future<dynamic> get(String path) =>
      _request('GET', path, retryOnNetworkError: true);

  Future<dynamic> post(String path, Map<String, dynamic> body) =>
      _request('POST', path, body: body);

  Future<dynamic> put(String path, Map<String, dynamic> body) =>
      _request('PUT', path, body: body);

  Future<dynamic> patch(String path, Map<String, dynamic> body) =>
      _request('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _request('DELETE', path);

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool retryOnNetworkError = false,
  }) async {
    // The query string may contain personal data (e.g. athlete search),
    // so it is never logged.
    final logPath = path.split('?').first;
    _logger.debug('API → $method $logPath');
    final stopwatch = Stopwatch()..start();
    var attempt = 0;

    while (true) {
      attempt++;
      try {
        final response = await _send(
          method,
          path,
          body,
        ).timeout(_requestTimeout);
        final result = _unwrap(response);
        _logger.info(
          'API ← ${response.statusCode} $method $logPath '
          '(${stopwatch.elapsedMilliseconds} ms)',
        );
        return result;
      } on ApiException catch (e) {
        _logger.error(
          'API ← ${e.statusCode} $method $logPath '
          '(${stopwatch.elapsedMilliseconds} ms)',
          error: e.message,
        );
        rethrow;
      } on TimeoutException catch (e) {
        if (retryOnNetworkError && attempt == 1) {
          await Future<void>.delayed(_retryWait);
          continue;
        }
        _logger.error('API $method $logPath timed out', error: e);
        throw const NetworkException(_timeoutMessage);
      } on http.ClientException catch (e) {
        // Offline / DNS / connection refused / CORS failure. http's IOClient
        // wraps SocketException into ClientException, so no dart:io import
        // is needed (keeps Web compiling).
        if (retryOnNetworkError && attempt == 1) {
          await Future<void>.delayed(_retryWait);
          continue;
        }
        _logger.error('API $method $logPath connection failed', error: e);
        throw const NetworkException(_offlineMessage);
      }
    }
  }

  Future<http.Response> _send(
    String method,
    String path,
    Map<String, dynamic>? body,
  ) {
    final uri = Uri.parse('$baseUrl$path');
    final encoded = body == null ? null : jsonEncode(body);

    switch (method) {
      case 'GET':
        return _client.get(uri, headers: _headers);
      case 'POST':
        return _client.post(uri, headers: _headers, body: encoded);
      case 'PUT':
        return _client.put(uri, headers: _headers, body: encoded);
      case 'PATCH':
        return _client.patch(uri, headers: _headers, body: encoded);
      case 'DELETE':
        return _client.delete(uri, headers: _headers);
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  dynamic _unwrap(http.Response response) {
    final status = response.statusCode;

    if (status == 401) {
      _logger.warning('API: Unauthorized (401) — session may be invalid');
      onUnauthorized?.call();
    }

    // A proxy/gateway can answer with HTML (502/504) or an empty body;
    // that must surface as an ApiException, not a FormatException.
    Map<String, dynamic>? decoded;
    try {
      final raw = jsonDecode(
        utf8.decode(response.bodyBytes, allowMalformed: true),
      );
      if (raw is Map<String, dynamic>) decoded = raw;
    } on FormatException {
      decoded = null;
    }

    final bool isOk = status >= 200 && status < 300;

    if (isOk && decoded != null && (decoded['success'] as bool? ?? false)) {
      return decoded['data'];
    }

    if (decoded == null) {
      throw ApiException(
        message: _invalidResponseMessage,
        statusCode: status,
        errors: const {},
      );
    }

    final rawErrors = decoded['errors'];
    final Map<String, dynamic> errors = rawErrors is Map<String, dynamic>
        ? rawErrors
        : {};

    throw ApiException(
      message: decoded['message'] as String? ?? 'Unexpected error',
      statusCode: status,
      errors: errors,
    );
  }
}
