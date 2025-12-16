import 'package:go_router/go_router.dart';
import 'package:safe_zone/authentication/view/authentication.dart';

GoRouter routerConfig = GoRouter(
  initialLocation: '/authentication',
  routes: [
    GoRoute(
      path: '/authentication',
      name: 'authentication',
      builder: (context, state) => const AuthenticationScreen(),
    ),
  ],
);
