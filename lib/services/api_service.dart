import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> _getHeadersWithAuth(String token) => {
        ..._defaultHeaders,
        'Authorization': 'Bearer $token',
      };

  // Generic GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? token,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers =
          token != null ? _getHeadersWithAuth(token) : _defaultHeaders;

      dev.log('GET Request: $uri');

      final response = await http.get(uri, headers: headers).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      dev.log('GET Error: $e');
      rethrow;
    }
  }

  // Generic POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers =
          token != null ? _getHeadersWithAuth(token) : _defaultHeaders;

      dev.log('POST Request: $uri');
      dev.log('POST Body: ${body != null ? json.encode(body) : 'null'}');

      final response = await http
          .post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      dev.log('POST Error: $e');
      rethrow;
    }
  }

  // Generic PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers =
          token != null ? _getHeadersWithAuth(token) : _defaultHeaders;

      dev.log('PUT Request: $uri');
      dev.log('PUT Body: ${body != null ? json.encode(body) : 'null'}');

      final response = await http
          .put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      dev.log('PUT Error: $e');
      rethrow;
    }
  }

  // Generic DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = _buildUri(endpoint, queryParams);
      final headers =
          token != null ? _getHeadersWithAuth(token) : _defaultHeaders;

      dev.log('DELETE Request: $uri');

      final response =
          await http.delete(uri, headers: headers).timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      dev.log('DELETE Error: $e');
      rethrow;
    }
  }

  // Build URI with query parameters
  static Uri _buildUri(String endpoint, Map<String, String>? queryParams) {
    final uri = Uri.parse(endpoint);

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }

    return uri;
  }

  // Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    dev.log('Response Status: ${response.statusCode}');
    dev.log('Response Body: ${response.body}');

    try {
      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data is Map<String, dynamic> ? data : {'data': data};
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: data['message'] ?? 'API request failed',
          data: data,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      // Handle JSON decode errors
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'data': response.body};
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Failed to parse response',
        );
      }
    }
  }
}

// Custom exception for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  ApiException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() {
    return 'ApiException: $statusCode - $message';
  }
}
