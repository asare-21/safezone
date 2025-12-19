# Geofencing and Safe Zone Notifications Implementation

## Overview

This implementation adds geofencing capabilities to SafeZone, allowing users to define safe zones (e.g., home, school, work) and receive notifications when entering or exiting these areas.

## Features

### 1. Safe Zone Management

Users can create and manage multiple safe zones with the following properties:

- **Name**: Custom name for the zone (e.g., "Home", "Office")
- **Type**: Predefined categories (Home, Work, School, Custom)
- **Location**: GPS coordinates (latitude/longitude)
  - Manual entry
  - Use current location via "Use Current" button
- **Radius**: Customizable from 100m to 5km
- **Notifications**:
  - Toggle for entry notifications
  - Toggle for exit notifications
- **Active/Inactive**: Enable or disable individual zones

### 2. Geofencing Service

The `GeofencingService` monitors user location in the background and triggers events when:
- User enters a safe zone (if notifications enabled)
- User exits a safe zone (if notifications enabled)

**Key Features:**
- Efficient location monitoring (50-meter distance filter)
- Medium accuracy to balance battery usage
- Automatic permission handling
- Real-time zone state tracking

### 3. User Interface

#### Safe Zones Screen
- Displays all created safe zones
- Shows zone status (active/inactive)
- Indicates notification settings (entry/exit)
- Quick toggle for enabling/disabling zones
- Edit and delete actions

#### Safe Zone Form Screen
- Add new safe zones
- Edit existing zones
- Location selection with current location helper
- Visual type selection with chips
- Radius slider with visual feedback
- Notification preference toggles

### 4. Navigation

Safe Zones management is accessible from:
- Profile/Settings screen
- Under the "ACCOUNT" section
- Above "My Incident History"

## Technical Implementation

### Models

**SafeZone** (`lib/profile/models/safe_zone_model.dart`)
- Equatable model for comparison
- JSON serialization/deserialization
- `contains()` method for zone containment check using Distance calculations

### Repository

**SafeZoneRepository** (`lib/profile/repository/safe_zone_repository.dart`)
- Persistent storage using SharedPreferences
- CRUD operations: load, save, add, update, delete
- JSON-based storage format

**GeofencingService** (`lib/profile/repository/geofencing_service.dart`)
- Location monitoring using geolocator package
- Event-based architecture with callbacks
- Zone entry/exit detection
- Battery-optimized settings

### State Management

**SafeZoneCubit** (`lib/profile/cubit/safe_zone_cubit.dart`)
- BLoC pattern for state management
- Actions: loadSafeZones, addSafeZone, updateSafeZone, deleteSafeZone, toggleSafeZone
- Error handling with status states

**SafeZoneState** (`lib/profile/cubit/safe_zone_state.dart`)
- Status: initial, loading, success, error
- Safe zones list
- Error message

### Notifications

**GeofencingNotificationHelper** (`lib/profile/utils/geofencing_notification_helper.dart`)
- Integrates with geofencing service
- Handles zone entry/exit events
- Placeholder for notification implementation
- Ready for integration with flutter_local_notifications or Firebase Cloud Messaging

## Permissions

### Android

Added to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
```

This is required for monitoring location when the app is in the background.

## Testing

Comprehensive test coverage includes:

1. **Model Tests** (`test/profile/models/safe_zone_model_test.dart`)
   - Creation with required and optional fields
   - copyWith functionality
   - JSON serialization/deserialization
   - Zone containment calculations
   - Type display names

2. **Repository Tests** (`test/profile/repository/safe_zone_repository_test.dart`)
   - Loading safe zones
   - Saving safe zones
   - Adding, updating, deleting zones
   - Empty state handling
   - Error handling

3. **Cubit Tests** (`test/profile/cubit/safe_zone_cubit_test.dart`)
   - State transitions
   - CRUD operations
   - Toggle functionality
   - Error scenarios

## Usage

### For Users

1. Navigate to Settings (Profile tab)
2. Tap on "Safe Zones"
3. Tap the floating action button to add a zone
4. Fill in zone details:
   - Name the zone
   - Select type (Home/Work/School/Custom)
   - Set location (manual or current)
   - Adjust radius
   - Configure notifications
5. Save the zone
6. Toggle zones on/off as needed
7. Edit or delete zones using the action buttons

### For Developers

#### Initialize Geofencing

```dart
final geofencingHelper = GeofencingNotificationHelper();
await geofencingHelper.startMonitoring();
```

#### Stop Monitoring

```dart
geofencingHelper.stopMonitoring();
```

#### Access Safe Zones

```dart
final cubit = context.read<SafeZoneCubit>();
await cubit.loadSafeZones();
final zones = cubit.state.safeZones;
```

## Future Enhancements

Potential improvements for future iterations:

1. **Local Notifications**: Integrate flutter_local_notifications for actual push notifications
2. **Map View**: Visual representation of safe zones on a map
3. **Zone Templates**: Quick presets for common locations
4. **Geofence Analytics**: Track entry/exit history
5. **Multiple Radii**: Support for different alert radii within the same zone
6. **Time-based Rules**: Conditional notifications based on time of day
7. **Shared Zones**: Allow sharing safe zones with contacts
8. **Smart Suggestions**: AI-based suggestions for common locations

## Dependencies

- `geolocator: ^13.0.2` - Location services
- `latlong2: ^0.9.1` - Coordinate calculations
- `shared_preferences: ^2.3.4` - Data persistence
- `equatable: ^2.0.7` - Value comparison
- `bloc: ^9.0.0` / `flutter_bloc: ^9.1.1` - State management

## Security Considerations

- Location data is stored locally using SharedPreferences
- No location data is transmitted to external servers
- Background location permission requires user consent
- Users have full control over zone activation
- Data can be cleared by deleting zones or app data

## Performance

- Geofencing uses medium accuracy to balance battery life
- Location updates trigger every 50 meters (configurable)
- Zone calculations use efficient distance algorithms
- Inactive zones are not monitored
- Persistent storage is lightweight (JSON)

## Compatibility

- Android: API level 21+ (with background location support on API 29+)
- iOS: iOS 11+ (requires location permissions)
- Web: Limited functionality (no background tracking)
