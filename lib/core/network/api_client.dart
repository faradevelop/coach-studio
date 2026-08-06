import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:coach_studio/core/network/api_exception.dart';

/// Thin HTTP wrapper responsible for:
/// - sending requests with JSON headers
/// - unwrapping the backend's standard envelope: { success, message, data|errors }
/// - throwing ApiException on failure so callers can handle it uniformly
class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

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

    throw ApiException(
      message: decoded['message'] as String? ?? 'Unexpected error',
      statusCode: response.statusCode,
      errors: decoded['errors'] as Map<String, dynamic>?,
    );
  }
}
