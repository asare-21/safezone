import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_zone/authentication/cubit/authentication_cubit.dart';
import 'package:safe_zone/authentication/cubit/authentication_state.dart';
import 'package:safe_zone/authentication/view/authentication.dart';
import 'package:safe_zone/emergency_services/emergency_services.dart';
import 'package:safe_zone/home/view/home.dart';

/// Creates a GoRouter with authentication-aware redirects
GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/authentication',
    redirect: (context, state) {
      final authState = context.read<AuthenticationCubit>().state;
      final isAuthenticated = authState is AuthenticationAuthenticated;
      final isLoading = authState is AuthenticationLoading;
      final isAuthenticating = state.matchedLocation == '/authentication';

      // Don't redirect while checking authentication to avoid flicker
      if (isLoading) {
        return null;
      }

      // If user is authenticated and trying to access auth screen, redirect to home
      if (isAuthenticated && isAuthenticating) {
        return '/';
      }

      // If user is not authenticated and trying to access protected routes
      if (!isAuthenticated && !isAuthenticating) {
        return '/authentication';
      }

      // No redirect needed
      return null;
    },
    refreshListenable: GoRouterRefreshStream(
      context.read<AuthenticationCubit>().stream,
    ),
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/authentication',
        name: 'authentication',
        builder: (context, state) => const AuthenticationScreen(),
      ),
      GoRoute(
        path: '/emergency-services',
        name: 'emergency-services',
        builder: (context, state) => const EmergencyServicesScreen(),
      ),
    ],
  );
}

/// Helper class to refresh GoRouter when authentication state changes
/// Note: This is created once during app initialization and shares the lifecycle
/// of the app itself, so no explicit disposal is needed.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthenticationState> stream) {
    // Bloc streams are already broadcast streams, no need to convert
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthenticationState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
