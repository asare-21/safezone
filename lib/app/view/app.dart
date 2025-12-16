import 'package:flutter/material.dart';
import 'package:safe_zone/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      title: 'Safe Zone',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ShadThemeData(
        colorScheme: const ShadBlueColorScheme.light(),
      ),
      darkTheme: ShadThemeData(
        colorScheme: const ShadBlueColorScheme.dark(),
      ),
    );
  }
}
