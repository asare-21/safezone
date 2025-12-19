/// Auth0 authentication service
library;

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service to handle Auth0 authentication operations
class Auth0Service {
  Auth0Service({
    required String domain,
    required String clientId,
    FlutterSecureStorage? secureStorage,
  })  : _auth0 = Auth0(domain, clientId),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final Auth0 _auth0;
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'auth0_access_token';
  static const String _idTokenKey = 'auth0_id_token';
  static const String _refreshTokenKey = 'auth0_refresh_token';

  /// Login using Auth0 Universal Login
  Future<Credentials> login() async {
    try {
      final credentials = await _auth0.webAuthentication().login();
      await _storeCredentials(credentials);
      return credentials;
    } on WebAuthenticationException catch (e) {
      if (e.code == 'a0.session.user_cancelled') {
        throw Auth0Exception('Login was cancelled');
      } else if (e.code == 'a0.session.invalid_credentials') {
        throw Auth0Exception('Invalid credentials');
      }
      throw Auth0Exception('Login failed. Please try again.');
    } catch (e) {
      throw Auth0Exception('Login failed. Please try again.');
    }
  }

  /// Logout from Auth0
  Future<void> logout() async {
    try {
      await _auth0.webAuthentication().logout();
      await _clearCredentials();
    } on WebAuthenticationException catch (e) {
      // Log the error but clear credentials anyway
      await _clearCredentials();
      throw Auth0Exception('Logout completed with errors');
    } catch (e) {
      // Ensure credentials are cleared even if logout fails
      await _clearCredentials();
      throw Auth0Exception('Logout completed with errors');
    }
  }

  /// Get the current access token
  Future<String?> getAccessToken() async {
    return _secureStorage.read(key: _accessTokenKey);
  }

  /// Get the current ID token
  Future<String?> getIdToken() async {
    return _secureStorage.read(key: _idTokenKey);
  }

  /// Get the current refresh token
  Future<String?> getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Renew credentials using refresh token
  Future<Credentials?> renewCredentials() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return null;
      }

      final credentials = await _auth0
          .api
          .renewCredentials(refreshToken: refreshToken);
      await _storeCredentials(credentials);
      return credentials;
    } catch (e) {
      // If renewal fails, clear credentials
      await _clearCredentials();
      return null;
    }
  }

  /// Get user information from Auth0
  Future<UserProfile> getUserInfo() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        throw Auth0Exception('No access token available');
      }

      return _auth0.api.userProfile(accessToken: accessToken);
    } catch (e) {
      throw Auth0Exception('Failed to get user info: $e');
    }
  }

  /// Store credentials securely
  Future<void> _storeCredentials(Credentials credentials) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: credentials.accessToken,
    );
    await _secureStorage.write(
      key: _idTokenKey,
      value: credentials.idToken,
    );
    if (credentials.refreshToken != null) {
      await _secureStorage.write(
        key: _refreshTokenKey,
        value: credentials.refreshToken,
      );
    }
  }

  /// Clear all stored credentials
  Future<void> _clearCredentials() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _idTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}

/// Auth0 exception class
class Auth0Exception implements Exception {
  Auth0Exception(this.message);
  final String message;

  @override
  String toString() => 'Auth0Exception: $message';
}
