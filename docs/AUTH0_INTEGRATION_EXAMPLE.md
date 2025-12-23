# Auth0 Integration Example

This file shows example code for integrating Auth0 into the SafeZone app.

## Step 1: Update `lib/app/view/app.dart`

Add Auth0Service and AuthenticationCubit to your app:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_zone/alerts/alerts.dart';
import 'package:safe_zone/authentication/authentication.dart'; // Add this
import 'package:safe_zone/guide/guide.dart';
import 'package:safe_zone/home/home.dart';
import 'package:safe_zone/l10n/l10n.dart';
import 'package:safe_zone/map/map.dart';
import 'package:safe_zone/profile/profile.dart';
import 'package:safe_zone/profile/repository/safe_zone_repository.dart';
import 'package:safe_zone/user_settings/services/user_preferences_api_service.dart';
import 'package:safe_zone/utils/router_config.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatelessWidget {
  const App({required this.prefs, super.key});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    // Initialize Auth0 service
    final auth0Service = Auth0Service(
      domain: Auth0Config.domain,
      clientId: Auth0Config.clientId,
    );

    // Initialize API client with authentication
    final apiClient = ApiClient(
      auth0Service: auth0Service,
      baseUrl: 'http://10.0.2.2:8000', // Android emulator
    );

    // Initialize user preferences API service
    final userPreferencesApiService = UserPreferencesApiService(
      baseUrl: 'http://10.0.2.2:8000',
      // Pass apiClient to use authenticated requests
      // httpClient: apiClient,
    );

    // Initialize guide API service
    final guideApiService = GuideApiService(
      baseUrl: 'http://10.0.2.2:8000',
    );

    return MultiBlocProvider(
      providers: [
        // Add AuthenticationCubit as first provider
        BlocProvider(
          create: (_) => AuthenticationCubit(
            auth0Service: auth0Service,
          )..checkAuthentication(),
        ),
        BlocProvider(
          create: (_) => ProfileSettingsCubit(
            ProfileSettingsRepository(
              prefs,
              apiService: userPreferencesApiService,
            ),
          ),
        ),
        BlocProvider(
          create: (_) => BottomNavigationCubit(),
        ),
        BlocProvider(
          create: (_) => MapFilterCubit(),
        ),
        BlocProvider(
          create: (_) => AlertFilterCubit(),
        ),
        BlocProvider(
          create: (_) => ProfileCubit(
            sharedPreferences: prefs,
            apiService: userPreferencesApiService,
          )..loadSettings(),
        ),
        BlocProvider(
          create: (_) => NotificationSettingsCubit(
            sharedPreferences: prefs,
            apiService: userPreferencesApiService,
          ),
        ),
        BlocProvider(
          create: (_) => SafeZoneCubit(
            repository: SafeZoneRepository(sharedPreferences: prefs),
          ),
        ),
        BlocProvider(
          create: (_) => GuideCubit(
            apiService: guideApiService,
          )..loadGuides(),
        ),
      ],
      child: ShadApp.router(
        title: 'Safe Zone',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: routerConfig,
        theme: ShadThemeData(
          colorScheme: const ShadBlueColorScheme.light(),
        ),
        darkTheme: ShadThemeData(
          colorScheme: const ShadBlueColorScheme.dark(),
        ),
      ),
    );
  }
}
```

## Step 2: Update Router Configuration

Update `lib/utils/router_config.dart` to check authentication state:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_zone/authentication/authentication.dart';

final routerConfig = GoRouter(
  initialLocation: '/auth', // Start at auth screen
  redirect: (context, state) {
    // Get authentication state
    final authState = context.read<AuthenticationCubit>().state;
    
    final isOnAuthPage = state.matchedLocation == '/auth';
    final isAuthenticated = authState is AuthenticationAuthenticated;
    
    // Redirect to auth if not authenticated
    if (!isAuthenticated && !isOnAuthPage) {
      return '/auth';
    }
    
    // Redirect to home if authenticated and on auth page
    if (isAuthenticated && isOnAuthPage) {
      return '/';
    }
    
    return null; // No redirect needed
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthenticationScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    // ... other routes
  ],
);
```

## Step 3: Update API Services to Use Authenticated Client

Example for incident reporting service:

```dart
import 'package:safe_zone/authentication/authentication.dart';

class IncidentApiService {
  IncidentApiService({
    required Auth0Service auth0Service,
    required String baseUrl,
  }) : _apiClient = ApiClient(
          auth0Service: auth0Service,
          baseUrl: baseUrl,
        );

  final ApiClient _apiClient;

  Future<void> createIncident(Map<String, dynamic> incidentData) async {
    try {
      final response = await _apiClient.post(
        '/api/incidents/',
        body: incidentData,
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to create incident: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating incident: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getIncidents() async {
    try {
      final response = await _apiClient.get('/api/incidents/');

      if (response.statusCode != 200) {
        throw Exception('Failed to get incidents: ${response.body}');
      }

      final data = jsonDecode(response.body) as List;
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error getting incidents: $e');
    }
  }
}
```

## Step 4: Add Logout to Profile Screen

Update profile screen to include logout:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_zone/authentication/authentication.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          // ... other profile widgets
          
          // Logout button
          BlocBuilder<AuthenticationCubit, AuthenticationState>(
            builder: (context, state) {
              if (state is AuthenticationAuthenticated) {
                return ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  subtitle: Text(state.userEmail ?? 'Logged in'),
                  onTap: () {
                    context.read<AuthenticationCubit>().logout();
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
```

## Step 5: Handle 401 Errors (Token Refresh)

Create a middleware to handle token expiration:

```dart
import 'package:http/http.dart' as http;
import 'package:safe_zone/authentication/authentication.dart';

class AuthenticatedHttpClientWithRefresh extends http.BaseClient {
  AuthenticatedHttpClientWithRefresh({
    required Auth0Service auth0Service,
    required AuthenticationCubit authCubit,
    http.Client? innerClient,
  })  : _auth0Service = auth0Service,
        _authCubit = authCubit,
        _innerClient = innerClient ?? http.Client();

  final Auth0Service _auth0Service;
  final AuthenticationCubit _authCubit;
  final http.Client _innerClient;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Get the access token
    var accessToken = await _auth0Service.getAccessToken();

    // Add Authorization header if token exists
    if (accessToken != null && accessToken.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Send the request
    var response = await _innerClient.send(request);

    // If 401, try to refresh token and retry
    if (response.statusCode == 401) {
      // Try to refresh the token
      await _authCubit.refreshToken();
      
      // Get new token
      accessToken = await _auth0Service.getAccessToken();
      
      if (accessToken != null) {
        // Clone the request with new token
        final newRequest = _cloneRequest(request);
        newRequest.headers['Authorization'] = 'Bearer $accessToken';
        response = await _innerClient.send(newRequest);
      }
    }

    return response;
  }

  http.BaseRequest _cloneRequest(http.BaseRequest request) {
    if (request is http.Request) {
      final newRequest = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..bodyBytes = request.bodyBytes;
      return newRequest;
    }
    throw UnsupportedError('Request type not supported for cloning');
  }

  @override
  void close() {
    _innerClient.close();
    super.close();
  }
}
```

## Complete Integration Checklist

- [ ] Update `lib/authentication/config/auth0_config.dart` with your Auth0 credentials
- [ ] Add AuthenticationCubit to app providers
- [ ] Update router to check authentication state
- [ ] Update API services to use ApiClient
- [ ] Add logout functionality to profile screen
- [ ] Test login flow
- [ ] Test authenticated API calls
- [ ] Test token refresh
- [ ] Test logout flow
- [ ] Configure platform-specific settings (iOS/Android)
