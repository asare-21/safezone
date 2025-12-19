import 'package:bloc/bloc.dart';
import '../services/auth0_service.dart';
import 'authentication_state.dart';

/// Cubit to manage authentication state
class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({
    required Auth0Service auth0Service,
  })  : _auth0Service = auth0Service,
        super(const AuthenticationInitial());

  final Auth0Service _auth0Service;

  /// Check if user is already authenticated
  Future<void> checkAuthentication() async {
    emit(const AuthenticationLoading());
    try {
      final isAuthenticated = await _auth0Service.isAuthenticated();
      if (isAuthenticated) {
        final accessToken = await _auth0Service.getAccessToken();
        if (accessToken != null) {
          try {
            final userInfo = await _auth0Service.getUserInfo();
            emit(
              AuthenticationAuthenticated(
                accessToken: accessToken,
                userName: userInfo.name,
                userEmail: userInfo.email,
              ),
            );
          } catch (e) {
            // If we can't get user info, just use the token
            emit(AuthenticationAuthenticated(accessToken: accessToken));
          }
        } else {
          emit(const AuthenticationUnauthenticated());
        }
      } else {
        emit(const AuthenticationUnauthenticated());
      }
    } catch (e) {
      emit(AuthenticationError('Failed to check authentication: $e'));
    }
  }

  /// Login with Auth0
  Future<void> login() async {
    emit(const AuthenticationLoading());
    try {
      final credentials = await _auth0Service.login();
      try {
        final userInfo = await _auth0Service.getUserInfo();
        emit(
          AuthenticationAuthenticated(
            accessToken: credentials.accessToken,
            userName: userInfo.name,
            userEmail: userInfo.email,
          ),
        );
      } catch (e) {
        // If we can't get user info, just use the token
        emit(
          AuthenticationAuthenticated(
            accessToken: credentials.accessToken,
          ),
        );
      }
    } catch (e) {
      emit(AuthenticationError('Login failed: $e'));
      // Wait briefly to allow listeners to process error before clearing
      await Future<void>.delayed(const Duration(milliseconds: 100));
      emit(const AuthenticationUnauthenticated());
    }
  }

  /// Logout from Auth0
  Future<void> logout() async {
    emit(const AuthenticationLoading());
    try {
      await _auth0Service.logout();
      emit(const AuthenticationUnauthenticated());
    } catch (e) {
      emit(AuthenticationError('Logout failed: $e'));
      // Wait briefly to allow listeners to process error before clearing
      await Future<void>.delayed(const Duration(milliseconds: 100));
      emit(const AuthenticationUnauthenticated());
    }
  }

  /// Refresh the access token
  Future<void> refreshToken() async {
    try {
      final credentials = await _auth0Service.renewCredentials();
      if (credentials != null) {
        try {
          final userInfo = await _auth0Service.getUserInfo();
          emit(
            AuthenticationAuthenticated(
              accessToken: credentials.accessToken,
              userName: userInfo.name,
              userEmail: userInfo.email,
            ),
          );
        } catch (e) {
          // If we can't get user info, just use the token
          emit(
            AuthenticationAuthenticated(
              accessToken: credentials.accessToken,
            ),
          );
        }
      } else {
        emit(const AuthenticationUnauthenticated());
      }
    } catch (e) {
      emit(const AuthenticationUnauthenticated());
    }
  }
}
