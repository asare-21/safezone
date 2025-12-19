import 'package:go_router/go_router.dart';
import 'package:safe_zone/authentication/view/authentication.dart';
import 'package:safe_zone/emergency_services/emergency_services.dart';
import 'package:safe_zone/home/view/home.dart';

GoRouter routerConfig = GoRouter(
  initialLocation: '/authentication',

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
