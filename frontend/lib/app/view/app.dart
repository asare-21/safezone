import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_zone/alerts/alerts.dart';
import 'package:safe_zone/home/home.dart';
import 'package:safe_zone/l10n/l10n.dart';
import 'package:safe_zone/map/map.dart';
import 'package:safe_zone/profile/profile.dart';
import 'package:safe_zone/profile/repository/safe_zone_repository.dart';
import 'package:safe_zone/utils/router_config.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatelessWidget {
  const App({required this.prefs, super.key});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProfileSettingsCubit(
            ProfileSettingsRepository(prefs),
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
          create: (_) => ProfileCubit(sharedPreferences: prefs)..loadSettings(),
        ),
        BlocProvider(
          create: (_) => NotificationSettingsCubit(
            sharedPreferences: prefs,
          ),
        ),
        BlocProvider(
          create: (_) => SafeZoneCubit(
            repository: SafeZoneRepository(sharedPreferences: prefs),
          ),
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
