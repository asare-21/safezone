import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:safe_zone/firebase_options.dart';
import 'package:safe_zone/user_settings/services/device_api_service.dart';
import 'package:safe_zone/user_settings/services/firebase_init_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function(SharedPreferences) builder,
) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    log('Firebase initialized successfully');

    // Initialize Firebase Messaging and register device
    const baseUrl = 'http://127.0.0.1:8000';
    final deviceApiService = DeviceApiService(baseUrl: baseUrl);
    final firebaseInitService = FirebaseInitService(
      deviceApiService: deviceApiService,
    );
    
    // Initialize Firebase Messaging (non-blocking)
    firebaseInitService.initialize().catchError((error) {
      log('Firebase Messaging initialization failed: $error');
      // Continue app initialization even if FCM setup fails
    });
  } on FirebaseException catch (e) {
    log(
      'Firebase initialization failed: $e. App will continue without Firebase.',
    );
  }

  // Add cross-flavor configuration here
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(await builder(prefs));
}
