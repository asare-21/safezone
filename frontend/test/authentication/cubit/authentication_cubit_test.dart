import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/authentication/cubit/authentication_cubit.dart';
import 'package:safe_zone/authentication/cubit/authentication_state.dart';
import 'package:safe_zone/authentication/services/auth0_service.dart';

class MockAuth0Service extends Mock implements Auth0Service {}

class MockCredentials extends Mock implements Credentials {}

class MockUserProfile extends Mock implements UserProfile {}

void main() {
  group('AuthenticationCubit', () {
    late MockAuth0Service mockAuth0Service;
    late MockCredentials mockCredentials;
    late MockUserProfile mockUserProfile;

    setUp(() {
      mockAuth0Service = MockAuth0Service();
      mockCredentials = MockCredentials();
      mockUserProfile = MockUserProfile();
    });

    test('initial state is AuthenticationInitial', () {
      final cubit = AuthenticationCubit(auth0Service: mockAuth0Service);
      expect(cubit.state, const AuthenticationInitial());
    });

    group('checkAuthentication', () {
      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [Loading, Authenticated] when user has valid session',
        setUp: () {
          when(() => mockAuth0Service.isAuthenticated())
              .thenAnswer((_) async => true);
          when(() => mockAuth0Service.getAccessToken())
              .thenAnswer((_) async => 'test_token');
          when(() => mockAuth0Service.getUserInfo())
              .thenAnswer((_) async => mockUserProfile);
          when(() => mockUserProfile.name).thenReturn('Test User');
          when(() => mockUserProfile.email).thenReturn('test@example.com');
        },
        build: () => AuthenticationCubit(auth0Service: mockAuth0Service),
        act: (cubit) => cubit.checkAuthentication(),
        expect: () => [
          const AuthenticationLoading(),
          const AuthenticationAuthenticated(
            accessToken: 'test_token',
            userName: 'Test User',
            userEmail: 'test@example.com',
          ),
        ],
      );

      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [Loading, Authenticated] without user info when getUserInfo fails',
        setUp: () {
          when(() => mockAuth0Service.isAuthenticated())
              .thenAnswer((_) async => true);
          when(() => mockAuth0Service.getAccessToken())
              .thenAnswer((_) async => 'test_token');
          when(() => mockAuth0Service.getUserInfo())
              .thenThrow(Exception('Failed to get user info'));
        },
        build: () => AuthenticationCubit(auth0Service: mockAuth0Service),
        act: (cubit) => cubit.checkAuthentication(),
        expect: () => [
          const AuthenticationLoading(),
          const AuthenticationAuthenticated(accessToken: 'test_token'),
        ],
      );

      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [Loading, Unauthenticated] when user has no valid session',
        setUp: () {
          when(() => mockAuth0Service.isAuthenticated())
              .thenAnswer((_) async => false);
        },
        build: () => AuthenticationCubit(auth0Service: mockAuth0Service),
        act: (cubit) => cubit.checkAuthentication(),
        expect: () => [
          const AuthenticationLoading(),
          const AuthenticationUnauthenticated(),
        ],
      );

      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [Loading, Unauthenticated] when access token is null',
        setUp: () {
          when(() => mockAuth0Service.isAuthenticated())
              .thenAnswer((_) async => true);
          when(() => mockAuth0Service.getAccessToken())
              .thenAnswer((_) async => null);
        },
        build: () => AuthenticationCubit(auth0Service: mockAuth0Service),
        act: (cubit) => cubit.checkAuthentication(),
        expect: () => [
          const AuthenticationLoading(),
          const AuthenticationUnauthenticated(),
        ],
      );

      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [Loading, Error] when checking authentication fails',
        setUp: () {
          when(() => mockAuth0Service.isAuthenticated())
              .thenThrow(Exception('Network error'));
        },
        build: () => AuthenticationCubit(auth0Service: mockAuth0Service),
        act: (cubit) => cubit.checkAuthentication(),
        expect: () => [
          const AuthenticationLoading(),
          isA<AuthenticationError>(),
        ],
      );
    });

    group('login', () {
      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [Loading, Authenticated] on successful login',
        setUp: () {
          when(() => mockAuth0Service.login())
              .thenAnswer((_) async => mockCredentials);
          when(() => mockCredentials.accessToken).thenReturn('test_token');
          when(() => mockAuth0Service.getUserInfo())
              .thenAnswer((_) async => mockUserProfile);
          when(() => mockUserProfile.name).thenReturn('Test User');
          when(() => mockUserProfile.email).thenReturn('test@example.com');
        },
        build: () => AuthenticationCubit(auth0Service: mockAuth0Service),
        act: (cubit) => cubit.login(),
        expect: () => [
          const AuthenticationLoading(),
          const AuthenticationAuthenticated(
            accessToken: 'test_token',
            userName: 'Test User',
            userEmail: 'test@example.com',
          ),
        ],
      );

      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [Loading, Error, Unauthenticated] on login failure',
        setUp: () {
          when(() => mockAuth0Service.login())
              .thenThrow(Auth0Exception('Login failed'));
        },
        build: () => AuthenticationCubit(auth0Service: mockAuth0Service),
        act: (cubit) => cubit.login(),
        wait: const Duration(milliseconds: 200),
        expect: () => [
          const AuthenticationLoading(),
          isA<AuthenticationError>(),
          const AuthenticationUnauthenticated(),
        ],
      );
    });

    group('logout', () {
      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [Loading, Unauthenticated] on successful logout',
        setUp: () {
          when(() => mockAuth0Service.logout()).thenAnswer((_) async => {});
        },
        build: () => AuthenticationCubit(auth0Service: mockAuth0Service),
        act: (cubit) => cubit.logout(),
        expect: () => [
          const AuthenticationLoading(),
          const AuthenticationUnauthenticated(),
        ],
      );

      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits [Loading, Error, Unauthenticated] on logout failure',
        setUp: () {
          when(() => mockAuth0Service.logout())
              .thenThrow(Auth0Exception('Logout failed'));
        },
        build: () => AuthenticationCubit(auth0Service: mockAuth0Service),
        act: (cubit) => cubit.logout(),
        wait: const Duration(milliseconds: 200),
        expect: () => [
          const AuthenticationLoading(),
          isA<AuthenticationError>(),
          const AuthenticationUnauthenticated(),
        ],
      );
    });

    group('refreshToken', () {
      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits Authenticated on successful token refresh',
        setUp: () {
          when(() => mockAuth0Service.renewCredentials())
              .thenAnswer((_) async => mockCredentials);
          when(() => mockCredentials.accessToken).thenReturn('new_token');
          when(() => mockAuth0Service.getUserInfo())
              .thenAnswer((_) async => mockUserProfile);
          when(() => mockUserProfile.name).thenReturn('Test User');
          when(() => mockUserProfile.email).thenReturn('test@example.com');
        },
        build: () => AuthenticationCubit(auth0Service: mockAuth0Service),
        act: (cubit) => cubit.refreshToken(),
        expect: () => [
          const AuthenticationAuthenticated(
            accessToken: 'new_token',
            userName: 'Test User',
            userEmail: 'test@example.com',
          ),
        ],
      );

      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits Unauthenticated when credentials renewal returns null',
        setUp: () {
          when(() => mockAuth0Service.renewCredentials())
              .thenAnswer((_) async => null);
        },
        build: () => AuthenticationCubit(auth0Service: mockAuth0Service),
        act: (cubit) => cubit.refreshToken(),
        expect: () => [
          const AuthenticationUnauthenticated(),
        ],
      );

      blocTest<AuthenticationCubit, AuthenticationState>(
        'emits Unauthenticated on token refresh failure',
        setUp: () {
          when(() => mockAuth0Service.renewCredentials())
              .thenThrow(Exception('Refresh failed'));
        },
        build: () => AuthenticationCubit(auth0Service: mockAuth0Service),
        act: (cubit) => cubit.refreshToken(),
        expect: () => [
          const AuthenticationUnauthenticated(),
        ],
      );
    });
  });
}
