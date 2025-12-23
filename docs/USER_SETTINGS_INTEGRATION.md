# User Settings Backend Integration

This document describes how the SafeZone frontend (Flutter) connects to the backend (Django) for user preferences management.

## Overview

The user settings system allows users to customize their app experience with preferences for:
- Map settings (alert radius, default zoom, location icon)
- Notification settings (push notifications, proximity alerts, sound/vibration)
- Privacy settings (anonymous reporting)

All settings are synced with the backend API while maintaining local storage as a cache for offline functionality.

## Backend Implementation

### 1. Models

**UserPreferences Model** (`backend/safezone_backend/user_settings/models.py`)

```python
class UserPreferences(models.Model):
    device_id = models.CharField(max_length=255, unique=True, db_index=True)
    
    # Map Settings
    alert_radius = models.FloatField(default=5.0)  # in kilometers
    default_zoom = models.FloatField(default=15.0)
    location_icon = models.CharField(max_length=255, default='assets/fun_icons/icon1.png')
    
    # Notification Settings
    push_notifications = models.BooleanField(default=True)
    proximity_alerts = models.BooleanField(default=True)
    sound_vibration = models.BooleanField(default=True)
    
    # Privacy Settings
    anonymous_reporting = models.BooleanField(default=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
```

### 2. API Endpoints

All endpoints are prefixed with `/api/`

#### GET `/api/preferences/<device_id>/`
Retrieve user preferences for a device. If preferences don't exist, they are created with default values.

**Response:**
```json
{
  "id": 1,
  "device_id": "device-123",
  "alert_radius": 5.0,
  "default_zoom": 15.0,
  "location_icon": "assets/fun_icons/icon1.png",
  "push_notifications": true,
  "proximity_alerts": true,
  "sound_vibration": true,
  "anonymous_reporting": true,
  "created_at": "2025-12-19T15:00:00Z",
  "updated_at": "2025-12-19T15:00:00Z"
}
```

#### PATCH `/api/preferences/<device_id>/`
Update user preferences. Only provided fields are updated.

**Request:**
```json
{
  "alert_radius": 7.5,
  "push_notifications": false,
  "anonymous_reporting": false
}
```

**Response:**
```json
{
  "id": 1,
  "device_id": "device-123",
  "alert_radius": 7.5,
  "default_zoom": 15.0,
  "location_icon": "assets/fun_icons/icon1.png",
  "push_notifications": false,
  "proximity_alerts": true,
  "sound_vibration": true,
  "anonymous_reporting": false,
  "created_at": "2025-12-19T15:00:00Z",
  "updated_at": "2025-12-19T15:30:00Z"
}
```

### 3. Validation

The API validates all inputs:
- `alert_radius`: Between 0.5 and 10 km
- `default_zoom`: Between 10 and 18
- All boolean fields: Must be true or false

## Frontend Implementation

### 1. API Service

**UserPreferencesApiService** (`frontend/lib/user_settings/services/user_preferences_api_service.dart`)

Handles all HTTP communication with the backend for user preferences.

```dart
final apiService = UserPreferencesApiService(
  baseUrl: 'http://10.0.2.2:8000',  // Android emulator
);

// Get preferences
final prefs = await apiService.getPreferences('device-123');

// Update preferences
await apiService.updatePreferences(
  deviceId: 'device-123',
  alertRadius: 7.5,
  pushNotifications: false,
);
```

### 2. Repository Layer

**ProfileSettingsRepository** (`frontend/lib/profile/repository/profile_settings_repository.dart`)

Manages the local cache and backend sync for profile settings.

```dart
final repository = ProfileSettingsRepository(
  sharedPreferences,
  apiService: userPreferencesApiService,
);

// Load from backend
await repository.loadPreferencesFromBackend();

// Save setting (syncs to backend)
await repository.setAnonymousReporting(false);
```

### 3. State Management

**ProfileCubit** - Manages map settings (alert radius, default zoom, location icon)

```dart
// Update alert radius (syncs to backend)
context.read<ProfileCubit>().updateAlertRadius(7.5);

// Update default zoom (syncs to backend)
context.read<ProfileCubit>().updateDefaultZoom(16.0);

// Update location icon (syncs to backend)
context.read<ProfileCubit>().updateLocationIcon('assets/icons/courier.png');
```

**NotificationSettingsCubit** - Manages notification preferences

```dart
// Toggle push notifications (syncs to backend)
context.read<NotificationSettingsCubit>().togglePushNotifications(value: true);

// Toggle proximity alerts (syncs to backend)
context.read<NotificationSettingsCubit>().toggleProximityAlerts(value: false);

// Toggle sound and vibration (syncs to backend)
context.read<NotificationSettingsCubit>().toggleSoundVibration(value: true);
```

**ProfileSettingsCubit** - Manages privacy settings

```dart
// Toggle anonymous reporting (syncs to backend)
context.read<ProfileSettingsCubit>().setAnonymousReporting(false);
```

### 4. Offline Support

The app maintains a dual-storage strategy:
1. **Local Cache**: Settings are stored in SharedPreferences for immediate access
2. **Backend Sync**: Changes are synced to the backend when network is available

When the app starts:
1. Attempts to load settings from backend
2. Falls back to local storage if backend is unavailable
3. Updates local cache with backend values if successful

When settings change:
1. Updates immediately in local storage
2. Attempts to sync to backend in background
3. Continues operation even if backend sync fails

## Setup Instructions

### Backend Setup

1. **Install Dependencies**
```bash
cd backend/safezone_backend
pip install django==4.2.23 djangorestframework django-cors-headers
```

2. **Run Migrations**
```bash
python manage.py migrate
```

3. **Start Development Server**
```bash
python manage.py runserver 8000
```

### Frontend Configuration

The API base URL is configured in `frontend/lib/app/view/app.dart`:

**For Android Emulator:**
```dart
final userPreferencesApiService = UserPreferencesApiService(
  baseUrl: 'http://10.0.2.2:8000',
);
```

**For iOS Simulator:**
```dart
final userPreferencesApiService = UserPreferencesApiService(
  baseUrl: 'http://localhost:8000',
);
```

**For Physical Device:**
```dart
final userPreferencesApiService = UserPreferencesApiService(
  baseUrl: 'http://192.168.1.XXX:8000',  // Your computer's IP
);
```

## Testing

### Test Backend API

```bash
# Get preferences (creates default if not exists)
curl http://localhost:8000/api/preferences/test-device/

# Update preferences
curl -X PATCH http://localhost:8000/api/preferences/test-device/ \
  -H "Content-Type: application/json" \
  -d '{
    "alert_radius": 7.5,
    "push_notifications": false,
    "anonymous_reporting": false
  }'
```

### Test Frontend Integration

1. Start the backend server
2. Run the Flutter app on an emulator/device
3. Navigate to the Profile/Settings screen
4. Toggle any setting or adjust sliders
5. Check the backend admin panel or database to verify sync
6. Restart the app to verify settings are loaded from backend

## Admin Panel

Access the Django admin panel to manage user preferences:

1. Create a superuser:
```bash
cd backend/safezone_backend
python manage.py createsuperuser
```

2. Visit `http://localhost:8000/admin/`

3. Navigate to "User Preferences" to view and manage all user settings

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         Flutter App                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  ProfileCubit │  │ Notification │  │   Profile    │      │
│  │              │  │ SettingsCubit│  │SettingsCubit │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                   │              │
│  ┌──────▼─────────────────▼───────────────────▼───────┐    │
│  │      UserPreferencesApiService                      │    │
│  └──────┬──────────────────────────────────────────────┘    │
│         │                                                     │
│  ┌──────▼──────────────────────────────────────────────┐    │
│  │         SharedPreferences (Local Cache)             │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
└───────────────────────────┬─────────────────────────────────┘
                            │ HTTP API
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                      Django Backend                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────────────────────────────────────────┐    │
│  │  UserPreferencesView (API Endpoint)                │    │
│  └──────┬─────────────────────────────────────────────┘    │
│         │                                                     │
│  ┌──────▼─────────────────────────────────────────────┐    │
│  │  UserPreferencesSerializer                          │    │
│  └──────┬─────────────────────────────────────────────┘    │
│         │                                                     │
│  ┌──────▼─────────────────────────────────────────────┐    │
│  │  UserPreferences Model                              │    │
│  └──────┬─────────────────────────────────────────────┘    │
│         │                                                     │
│  ┌──────▼─────────────────────────────────────────────┐    │
│  │  SQLite Database                                     │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Key Features

1. **Automatic Creation**: Preferences are created automatically with defaults on first access
2. **Partial Updates**: Only changed fields are sent to the backend
3. **Offline Support**: App works with local cache when backend is unavailable
4. **Real-time Sync**: Changes are synced to backend immediately
5. **Graceful Degradation**: App continues working even if backend sync fails
6. **Type Safety**: Full type checking in both frontend and backend
7. **Validation**: Input validation on both client and server

## Future Enhancements

- [ ] User authentication for multi-device sync
- [ ] Conflict resolution for settings changed on multiple devices
- [ ] Settings export/import functionality
- [ ] Backend-triggered settings push to devices
- [ ] Settings history and rollback
- [ ] A/B testing for default settings
