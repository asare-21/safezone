# Push Notifications with Safe Zone Filtering

## Overview

The SafeZone backend now supports Firebase Cloud Messaging (FCM) push notifications with intelligent safe zone filtering. Users only receive notifications for incidents that occur within their designated safe zones.

## How It Works

### 1. Device Registration

Users register their devices with FCM tokens:

```bash
POST /api/devices/register/
{
  "device_id": "unique_device_identifier",
  "fcm_token": "firebase_cloud_messaging_token",
  "platform": "android"  # or "ios", "web"
}
```

### 2. Safe Zone Configuration

Users define safe zones where they want to be notified:

```bash
POST /api/safe-zones/
{
  "device_id": "unique_device_identifier",
  "name": "Home",
  "latitude": 5.6037,
  "longitude": -0.1870,
  "radius": 1000,  # meters
  "zone_type": "home"  # or "work", "school", "custom"
}
```

### 3. Incident Notification Logic

When a new incident is created:

1. **Safe Zone Check**: The system checks if any users have safe zones that contain the incident location
2. **Filtering**: 
   - ✅ **Users WITH safe zones** → Only notified if incident is WITHIN their safe zones
   - ❌ **Users WITHOUT safe zones** → NOT notified at all
3. **Notification Delivery**: FCM notifications sent to matching devices

## API Endpoints

### Device Management

**Register/Update Device**
```
POST /api/devices/register/
```

Request:
```json
{
  "device_id": "string",
  "fcm_token": "string",
  "platform": "android|ios|web",
  "is_active": true
}
```

### Safe Zone Management

**List Safe Zones**
```
GET /api/safe-zones/?device_id={device_id}
```

**Create Safe Zone**
```
POST /api/safe-zones/
```

Request:
```json
{
  "device_id": "string",
  "name": "string",
  "latitude": float,
  "longitude": float,
  "radius": float,
  "zone_type": "home|work|school|custom",
  "is_active": true,
  "notify_on_enter": true,
  "notify_on_exit": true
}
```

**Update Safe Zone**
```
PUT/PATCH /api/safe-zones/{id}/
```

**Delete Safe Zone**
```
DELETE /api/safe-zones/{id}/
```

## Firebase Setup

### Backend Configuration

1. **Get Firebase Service Account Key**
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save the JSON file

2. **Set Environment Variable**
   ```bash
   export FIREBASE_CREDENTIALS_PATH=/path/to/serviceAccountKey.json
   ```

3. **Start Server**
   ```bash
   python manage.py runserver
   ```

### Environment Variables

```bash
# Required for push notifications
FIREBASE_CREDENTIALS_PATH=/path/to/firebase-credentials.json
```

If not set, notifications will be logged but not sent.

## Notification Behavior

### Scenario 1: User with Safe Zones

```
User has safe zone "Home" at (5.6037, -0.1870) with radius 1000m

Incident A: (5.6040, -0.1875) - Within 50m of home
→ ✅ User IS notified

Incident B: (6.0000, -1.0000) - 50km away
→ ❌ User is NOT notified
```

### Scenario 2: User without Safe Zones

```
User has NO safe zones configured

Any incident anywhere:
→ ❌ User is NOT notified
```

### Scenario 3: User with Inactive Safe Zones

```
User has safe zones but all are is_active=false

Any incident anywhere:
→ ❌ User is NOT notified
```

## Notification Format

**Title**: `⚠️ {Category} Reported Nearby`

**Body**: `{Incident Title}` (truncated to 100 chars)

**Data Payload**:
```json
{
  "incident_id": "123",
  "category": "theft",
  "latitude": "5.6040",
  "longitude": "-0.1875",
  "timestamp": "2025-12-19T15:00:00Z",
  "type": "incident_alert"
}
```

## Admin Interface

The Django admin interface provides views for:

- **UserDevice**: View registered devices and FCM tokens
- **SafeZone**: View and manage user safe zones
- **NotificationLog**: View notification delivery history

Access at `http://localhost:8000/admin/`

## Testing

### Test Device Registration

```bash
curl -X POST http://localhost:8000/api/devices/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "test_device",
    "fcm_token": "test_token",
    "platform": "android"
  }'
```

### Test Safe Zone Creation

```bash
curl -X POST http://localhost:8000/api/safe-zones/ \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "test_device",
    "name": "Home",
    "latitude": 5.6037,
    "longitude": -0.1870,
    "radius": 1000,
    "zone_type": "home"
  }'
```

### Test Incident (Within Safe Zone)

```bash
curl -X POST http://localhost:8000/api/incidents/ \
  -H "Content-Type: application/json" \
  -d '{
    "category": "theft",
    "latitude": 5.6040,
    "longitude": -0.1875,
    "title": "Test Incident",
    "description": "Within safe zone",
    "notify_nearby": true
  }'
```

Check logs: Should see "Incident within safe zone"

### Test Incident (Outside Safe Zone)

```bash
curl -X POST http://localhost:8000/api/incidents/ \
  -H "Content-Type: application/json" \
  -d '{
    "category": "fire",
    "latitude": 6.0000,
    "longitude": -1.0000,
    "title": "Test Incident",
    "description": "Outside safe zone",
    "notify_nearby": true
  }'
```

Check logs: Should see "No safe zones contain this incident location"

## Frontend Integration

The frontend already has safe zone models and repositories. To integrate:

1. **Register Device on App Start**
   - Get FCM token from Firebase
   - Send to `/api/devices/register/`

2. **Sync Safe Zones**
   - When user creates/updates safe zones in app
   - POST/PUT to `/api/safe-zones/`

3. **Handle Notifications**
   - Listen for FCM messages
   - Parse incident_id from data payload
   - Show incident on map or in alerts list

## Frontend Integration

The frontend has been updated with services to handle device registration and safe zone synchronization.

### Services Created

1. **DeviceApiService** (`lib/user_settings/services/device_api_service.dart`)
   - Registers device with FCM token
   - Updates device registration when token refreshes

2. **SafeZoneApiService** (`lib/user_settings/services/safe_zone_api_service.dart`)
   - CRUD operations for safe zones
   - Syncs local safe zones with backend

3. **FirebaseInitService** (`lib/user_settings/services/firebase_init_service.dart`)
   - Initializes Firebase Messaging
   - Requests notification permissions
   - Registers device on app start
   - Handles token refresh
   - Listens for incoming notifications

### Integration Steps

1. **Initialize Firebase on App Start**

Add to `main.dart` or app initialization:

```dart
import 'package:safe_zone/user_settings/services/device_api_service.dart';
import 'package:safe_zone/user_settings/services/firebase_init_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize device registration
  final deviceService = DeviceApiService(
    baseUrl: 'http://10.0.2.2:8000',  // Update for your environment
  );
  
  final firebaseInit = FirebaseInitService(
    deviceApiService: deviceService,
  );
  
  await firebaseInit.initialize();
  
  runApp(MyApp());
}
```

2. **Sync Safe Zones**

When user creates/updates safe zones in the app, sync with backend:

```dart
import 'package:safe_zone/user_settings/services/safe_zone_api_service.dart';

final safeZoneService = SafeZoneApiService(
  baseUrl: 'http://10.0.2.2:8000',
);

// Create safe zone
await safeZoneService.createSafeZone(
  deviceId: deviceId,
  safeZone: mySafeZone,
);

// Update safe zone
await safeZoneService.updateSafeZone(
  deviceId: deviceId,
  safeZone: updatedSafeZone,
);

// Delete safe zone
await safeZoneService.deleteSafeZone(safeZoneId);

// Load safe zones from backend
final safeZones = await safeZoneService.getSafeZones(deviceId);
```

3. **Handle Notifications**

Notifications are automatically handled by `FirebaseInitService`. To customize:

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Show in-app notification
  final incidentId = message.data['incident_id'];
  final category = message.data['category'];
  
  // Navigate to incident or show dialog
  showIncidentAlert(incidentId, category);
});
```

### Updating Safe Zone Repository

The existing `SafeZoneRepository` should be updated to use `SafeZoneApiService`:

```dart
// In lib/profile/repository/safe_zone_repository.dart
import 'package:safe_zone/user_settings/services/safe_zone_api_service.dart';

class SafeZoneRepository {
  final SafeZoneApiService _apiService;
  final SharedPreferences _prefs;
  
  // Save safe zone (sync with backend)
  Future<void> saveSafeZone(SafeZone safeZone) async {
    // Save locally
    await _saveToLocalStorage(safeZone);
    
    // Sync with backend
    try {
      final deviceId = _prefs.getString('device_id') ?? '';
      if (safeZone.id == 'new') {
        await _apiService.createSafeZone(
          deviceId: deviceId,
          safeZone: safeZone,
        );
      } else {
        await _apiService.updateSafeZone(
          deviceId: deviceId,
          safeZone: safeZone,
        );
      }
    } catch (e) {
      // Handle sync error (queue for retry, etc.)
      debugPrint('Failed to sync safe zone: $e');
    }
  }
  
  // Delete safe zone (sync with backend)
  Future<void> deleteSafeZone(String id) async {
    await _deleteFromLocalStorage(id);
    
    try {
      await _apiService.deleteSafeZone(id);
    } catch (e) {
      debugPrint('Failed to delete safe zone from backend: $e');
    }
  }
}
```

### Dependencies Added

```yaml
dependencies:
  device_info_plus: ^11.2.0  # For device identification
```

### Notification Payload Structure

When a notification arrives, it contains:

```json
{
  "notification": {
    "title": "⚠️ Theft Reported Nearby",
    "body": "Theft incident description..."
  },
  "data": {
    "incident_id": "123",
    "category": "theft",
    "latitude": "5.6040",
    "longitude": "-0.1875",
    "timestamp": "2025-12-19T15:00:00Z",
    "type": "incident_alert"
  }
}
```

Use `message.data` to extract incident details and navigate to the incident on the map.

## Security Considerations

- FCM tokens are sensitive - stored securely in database
- Firebase credentials must be kept secret (use environment variables)
- Safe zone locations reveal user privacy - only store if user opts in
- Notification logs help with debugging but contain user data - consider retention policy

## Troubleshooting

### No Notifications Sent

1. Check Firebase credentials: `echo $FIREBASE_CREDENTIALS_PATH`
2. Check logs for "Firebase not initialized" warning
3. Verify FCM token is valid
4. Check safe zone contains incident location

### Too Many Notifications

1. Check user has correct safe zones configured
2. Verify safe zone radius is appropriate
3. Check is_active flag on safe zones

### Notifications to Wrong Users

1. Verify safe zone device_id matches registered device
2. Check safe zone contains_point() calculation
3. Review NotificationLog in admin

## Future Enhancements

- [ ] Topic-based notifications for all users
- [ ] Notification preferences (mute categories, times)
- [ ] Rate limiting (max X notifications per hour)
- [ ] Notification history in user profile
- [ ] Web push notifications
- [ ] Custom notification sounds per category
