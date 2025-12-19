# Notification Settings Implementation

## Overview
This implementation adds persistent notification settings with Firebase Cloud Messaging integration. The settings are managed using a Cubit pattern with SharedPreferences for local persistence.

## Features Implemented

### Settings Managed
1. **Push Notifications** - Enable/disable FCM push notifications
2. **Proximity Alerts** - Subscribe/unsubscribe to proximity alerts topic
3. **Sound & Vibration** - Local preference for notification sounds
4. **Anonymous Reporting** - Toggle anonymous reporting mode
5. **Share Location with Contacts** - Control location sharing
6. **Alert Radius** - Configurable alert radius (0.5km - 10km)

### Architecture

#### State Management
- **NotificationSettingsCubit**: Manages notification settings state
- **NotificationSettingsState**: Immutable state using Equatable
- State persists across app restarts using SharedPreferences

#### Firebase Integration
- **Firebase Cloud Messaging (FCM)**: Push notification delivery
- **Topic Subscriptions**: 
  - `all_users` - All push notifications
  - `proximity_alerts` - Location-based alerts
- Graceful degradation if Firebase is not configured

## File Structure

```
lib/profile/
├── cubit/
│   ├── notification_settings_cubit.dart   # Main cubit logic
│   └── notification_settings_state.dart   # State definition
├── view/
│   └── profile.dart                        # Profile screen UI
└── profile.dart                            # Barrel file

test/profile/
└── cubit/
    └── notification_settings_cubit_test.dart  # Cubit tests
```

## Setup Instructions

### 1. Install Dependencies
Dependencies are already added to `pubspec.yaml`:
- `firebase_core: ^3.10.0`
- `firebase_messaging: ^15.1.6`
- `shared_preferences: ^2.3.4`
- `equatable: ^2.0.7`

Run:
```bash
flutter pub get
```

### 2. Firebase Configuration

#### For Android:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create or select your project
3. Add an Android app
4. Download `google-services.json`
5. Place it in `android/app/google-services.json`
6. Update `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
7. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

#### For iOS:
1. In Firebase Console, add an iOS app
2. Download `GoogleService-Info.plist`
3. Add to `ios/Runner/` in Xcode
4. Update `ios/Runner/Info.plist` with notification permissions

### 3. FlutterFire CLI (Alternative Setup)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase automatically
flutterfire configure
```

This will generate `lib/firebase_options.dart` and configure both platforms.

### 4. Update Bootstrap (if using FlutterFire CLI)
If you used FlutterFire CLI, update `lib/bootstrap.dart`:
```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Usage

### In UI Code
```dart
// Wrap screen with BlocProvider (already done in ProfileScreen)
BlocProvider(
  create: (context) => NotificationSettingsCubit(),
  child: const _ProfileView(),
)

// Access cubit in widgets
BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
  builder: (context, state) {
    final cubit = context.read<NotificationSettingsCubit>();
    return Switch(
      value: state.pushNotifications,
      onChanged: cubit.togglePushNotifications,
    );
  },
)
```

### Direct Cubit Usage
```dart
// Create cubit
final cubit = NotificationSettingsCubit();

// Toggle settings
await cubit.togglePushNotifications(true);
await cubit.updateAlertRadius(5.0);

// Listen to state
cubit.stream.listen((state) {
  print('Push notifications: ${state.pushNotifications}');
});
```

## Testing

Run tests:
```bash
flutter test test/profile/cubit/notification_settings_cubit_test.dart
```

The tests verify:
- Initial state values
- State updates for each setting
- Persistence to SharedPreferences
- Firebase topic subscriptions
- Loading settings from storage

## Error Handling

### Firebase Not Configured
If Firebase is not configured, the app will:
- Log a warning message
- Continue running without Firebase features
- Settings will still persist locally via SharedPreferences

### SharedPreferences Failure
If SharedPreferences fails:
- Settings still update in-memory state
- Changes won't persist across restarts
- No crash or error shown to user

## Migration Notes

### Before
- Settings used local `setState` in StatefulWidget
- No persistence across app restarts
- No Firebase integration

### After
- Settings managed by NotificationSettingsCubit
- Persisted using SharedPreferences
- Integrated with Firebase Cloud Messaging
- Profile screen is now StatelessWidget with BlocProvider

## Future Enhancements

Potential improvements:
1. Add analytics tracking for setting changes
2. Implement remote config for default settings
3. Add push notification scheduling
4. Implement notification categories/priorities
5. Add A/B testing for notification strategies
6. Create notification history/log

## Troubleshooting

### Tests Fail
Ensure you have:
```bash
flutter pub get
```

### FCM Not Working
1. Verify Firebase configuration files exist
2. Check Firebase project settings
3. Ensure app bundle ID matches Firebase console
4. Test on physical device (FCM may not work on emulators)

### Settings Not Persisting
1. Check SharedPreferences permissions
2. Verify no errors in console logs
3. Test on different devices/simulators

## References

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Bloc Pattern](https://bloclibrary.dev/)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)
- [Equatable](https://pub.dev/packages/equatable)
