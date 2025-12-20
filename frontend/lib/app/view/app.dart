import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_zone/alerts/alerts.dart';
import 'package:safe_zone/authentication/cubit/authentication_cubit.dart';
import 'package:safe_zone/authentication/services/auth0_service.dart';
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
    // Initialize user preferences API service
    // Use Android emulator localhost address by default
    final userPreferencesApiService = UserPreferencesApiService(
      baseUrl: 'http://10.0.2.2:8000', // Android emulator
      // baseUrl: 'http://localhost:8000', // iOS simulator / web
    );

    // Initialize guide API service
    final guideApiService = GuideApiService(
      baseUrl: 'http://10.0.2.2:8000', // Android emulator
      // baseUrl: 'http://localhost:8000', // iOS simulator / web
    );

    return MultiBlocProvider(
      providers: [
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
        BlocProvider(
          create: (_) => AuthenticationCubit(
            auth0Service: Auth0Service(
              domain: const String.fromEnvironment('AUTH0_DOMAIN'),
              clientId: const String.fromEnvironment('AUTH0_CLIENT_ID'),
            ),
          )..checkAuthentication(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return ShadApp.router(
            title: 'Safe Zone',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: createRouter(context),
            theme: ShadThemeData(
              colorScheme: const ShadBlueColorScheme.light(),
            ),
            darkTheme: ShadThemeData(
              colorScheme: const ShadBlueColorScheme.dark(),
            ),
          );
        },
      ),
    );
  }
}
