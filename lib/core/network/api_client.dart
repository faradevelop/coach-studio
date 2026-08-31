import 'dart:convert';
import 'package:http/http.dart' as http;
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

  /// Invoked whenever ANY request comes back with 401 Unauthorized. Wired
  /// up in `injection_container.dart` once `AuthCubit` exists, to avoid a
  /// circular dependency between the network layer and the auth feature.
  void Function()? onUnauthorized;

  ApiClient({
    required this.baseUrl,
    required this.tokenStorage,
    http.Client? client,
  }) : _client = client ?? http.Client();

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
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _unwrap(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _unwrap(response);
  }

  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final response = await _client.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _unwrap(response);
  }

  Future<dynamic> patch(String path, Map<String, dynamic> body) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _unwrap(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _unwrap(response);
  }

  dynamic _unwrap(http.Response response) {
    final Map<String, dynamic> decoded =
        jsonDecode(response.body) as Map<String, dynamic>;
    final bool success = decoded['success'] as bool? ?? false;

    if (response.statusCode >= 200 && response.statusCode < 300 && success) {
      return decoded['data'];
    }

    if (response.statusCode == 401) {
      onUnauthorized?.call();
    }

    throw ApiException(
      message: decoded['message'] as String? ?? 'Unexpected error',
      statusCode: response.statusCode,
      errors: decoded['errors'] as Map<String, dynamic>?,
    );
  }
}
