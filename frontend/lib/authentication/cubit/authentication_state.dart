import 'package:equatable/equatable.dart';

/// Authentication state
abstract class AuthenticationState extends Equatable {
  const AuthenticationState();

  @override
  List<Object?> get props => [];
}

/// Initial/unknown authentication state
class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();
}

/// User is authenticated
class AuthenticationAuthenticated extends AuthenticationState {
  const AuthenticationAuthenticated({
    required this.accessToken,
    this.userName,
    this.userEmail,
  });

  final String accessToken;
  final String? userName;
  final String? userEmail;

  @override
  List<Object?> get props => [accessToken, userName, userEmail];
}

/// User is not authenticated
class AuthenticationUnauthenticated extends AuthenticationState {
  const AuthenticationUnauthenticated();
}

/// Authentication is in progress
class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading();
}

/// Authentication error occurred
class AuthenticationError extends AuthenticationState {
  const AuthenticationError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
