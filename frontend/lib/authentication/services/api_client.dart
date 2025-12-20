import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safe_zone/authentication/services/auth0_service.dart';

/// HTTP client that automatically adds Auth0 JWT token to requests
class AuthenticatedHttpClient extends http.BaseClient {
  AuthenticatedHttpClient({
    required Auth0Service auth0Service,
    http.Client? innerClient,
  })  : _auth0Service = auth0Service,
        _innerClient = innerClient ?? http.Client();

  final Auth0Service _auth0Service;
  final http.Client _innerClient;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Get the access token
    final accessToken = await _auth0Service.getAccessToken();

    // Add Authorization header if token exists
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Add Content-Type header for JSON requests
    if (!request.headers.containsKey('Content-Type') &&
        (request.method == 'POST' ||
            request.method == 'PUT' ||
            request.method == 'PATCH')) {
      request.headers['Content-Type'] = 'application/json';
    }

    return _innerClient.send(request);
  }

  @override
  void close() {
    _innerClient.close();
    super.close();
  }
}

/// Helper class for making authenticated API calls
class ApiClient {
  ApiClient({
    required Auth0Service auth0Service,
    required String baseUrl,
  })  : _auth0Service = auth0Service,
        _baseUrl = baseUrl,
        _client = AuthenticatedHttpClient(auth0Service: auth0Service);

  final Auth0Service _auth0Service;
  final String _baseUrl;
  final AuthenticatedHttpClient _client;

  /// Make a GET request
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$_baseUrl$path');
    return _client.get(url, headers: headers);
  }

  /// Make a POST request
  Future<http.Response> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$_baseUrl$path');
    return _client.post(
      url,
      body: body != null ? jsonEncode(body) : null,
      headers: headers,
    );
  }

  /// Make a PUT request
  Future<http.Response> put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$_baseUrl$path');
    return _client.put(
      url,
      body: body != null ? jsonEncode(body) : null,
      headers: headers,
    );
  }

  /// Make a PATCH request
  Future<http.Response> patch(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$_baseUrl$path');
    return _client.patch(
      url,
      body: body != null ? jsonEncode(body) : null,
      headers: headers,
    );
  }

  /// Make a DELETE request
  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$_baseUrl$path');
    return _client.delete(url, headers: headers);
  }

  /// Close the client
  void close() {
    _client.close();
  }
}
