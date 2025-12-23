# Incident Confirmation Prompt Feature

## Overview

This feature prompts users when they approach reported incidents to confirm if the incident is still present. User confirmations help validate incident reports and earn users scoring points, contributing to their profile reputation.

## Key Features

- **Automatic proximity detection**: Monitors user location and detects nearby incidents within 500 meters
- **Smart prompting**: Only prompts users once per incident to avoid annoyance
- **Scoring integration**: Awards 5 points per confirmation
- **User-friendly dialogs**: Clean, informative UI for confirmation and results
- **Duplicate prevention**: Prevents users from confirming the same incident multiple times
- **Local tracking**: Stores prompted incidents locally to maintain state across app sessions

## Architecture

### Backend

#### New Endpoint: `/api/scoring/incidents/nearby/`

**Method**: POST

**Request Body**:
```json
{
  "latitude": 37.7749,
  "longitude": -122.4194,
  "device_id": "user_device_identifier",
  "radius_km": 0.5,
  "hours": 24
}
```

**Response**:
```json
{
  "count": 2,
  "incidents": [
    {
      "id": 1,
      "category": "theft",
      "title": "Theft Incident",
      "description": "Details...",
      "latitude": 37.7749,
      "longitude": -122.4194,
      "timestamp": "2025-12-23T08:00:00Z",
      "confirmed_by": 3,
      "distance_meters": 250.5
    }
  ]
}
```

**Functionality**:
- Filters incidents within specified radius using haversine distance calculation
- Excludes incidents the user has already confirmed
- Returns incidents from the last N hours (default: 24)
- Sorts results by distance (closest first)
- Maximum radius: 10km

#### Implementation Details

**File**: `/backend/safezone_backend/scoring/views.py`

- Added `NearbyIncidentsView` class
- Uses `haversine_distance` utility from alerts app
- Queries `IncidentConfirmation` model to filter out already-confirmed incidents
- Returns sorted list of nearby unconfirmed incidents

**File**: `/backend/safezone_backend/scoring/urls.py`

- Added route: `path('incidents/nearby/', NearbyIncidentsView.as_view(), name='nearby-incidents')`

### Frontend

#### Models

**File**: `/frontend/lib/profile/models/user_score_model.dart`

Added `NearbyIncident` class:
```dart
class NearbyIncident {
  final int id;
  final String category;
  final String title;
  final String? description;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final int confirmedBy;
  final double distanceMeters;
}
```

#### Repository

**File**: `/frontend/lib/profile/repository/scoring_repository.dart`

Added `getNearbyIncidents()` method:
```dart
Future<List<NearbyIncident>> getNearbyIncidents({
  required double latitude,
  required double longitude,
  required String deviceId,
  double radiusKm = 0.5,
  int hours = 24,
})
```

#### Services

**File**: `/frontend/lib/profile/repository/incident_proximity_service.dart`

The `IncidentProximityService` class handles:
- **Location monitoring**: Uses `geolocator` package to track user position
- **Periodic checks**: Queries backend every 30 seconds or when user moves 100 meters
- **Callback system**: Notifies registered callbacks when nearby incidents are detected
- **Local storage**: Stores prompted incident IDs in SharedPreferences
- **Duplicate prevention**: Checks local cache before showing prompts

Key methods:
- `startMonitoring()`: Initializes location tracking and periodic checks
- `stopMonitoring()`: Stops location tracking
- `onNearbyIncident()`: Registers callback for incident detection
- `clearPromptedIncidents()`: Clears local history (for testing)

#### User Interface

**File**: `/frontend/lib/profile/view/incident_confirmation_dialog.dart`

The `IncidentConfirmationDialog` widget displays:
- Incident details (category, title, description)
- Distance from user
- Time since incident was reported
- Number of existing confirmations
- "Yes, Confirm" and "Not Sure" buttons
- Points to be earned (+5 points)

**File**: `/frontend/lib/profile/view/confirmation_result_dialog.dart`

The `ConfirmationResultDialog` widget shows:
- Success icon and message
- Points earned (+5)
- Total points after confirmation
- Tier upgrade notification (if applicable)

#### Integration

**File**: `/frontend/lib/home/view/home.dart`

The home screen now:
1. Initializes `IncidentProximityService` on startup
2. Retrieves device ID using `device_info_plus`
3. Starts proximity monitoring with 500m radius
4. Handles nearby incident callbacks
5. Shows confirmation dialog when incident detected
6. Processes confirmation and shows result dialog
7. Handles errors gracefully

## User Flow

1. **App Launch**: User opens the app and grants location permissions
2. **Background Monitoring**: Service monitors user location in the background
3. **Incident Detection**: When user approaches within 500m of a reported incident:
   - System checks if user has already been prompted about this incident
   - If not, shows confirmation dialog
4. **User Confirmation**: User sees incident details and chooses:
   - **"Yes, Confirm"**: Confirms incident is still present
   - **"Not Sure"**: Dismisses the prompt without confirming
5. **Point Award**: If confirmed:
   - System awards 5 points to user's profile
   - Updates incident confirmation count
   - Shows success dialog with points earned
   - If tier changes, displays tier upgrade notification
6. **Local Tracking**: Stores incident ID locally to prevent future prompts

## Configuration

### Adjustable Parameters

In `IncidentProximityService`:
- `_defaultRadiusKm`: Detection radius (default: 0.5 km = 500 meters)
- `_checkIntervalSeconds`: How often to check for nearby incidents (default: 30 seconds)
- `distanceFilter`: Minimum distance change to trigger location update (default: 100 meters)

In `NearbyIncidentsView` (backend):
- `radius_km`: Maximum detection radius (default: 0.5, max: 10)
- `hours`: Time window for incidents (default: 24 hours)

## Privacy & Performance

### Privacy
- Device IDs are encrypted in the database using AES-256
- Location data is only used for proximity checks, not stored
- Users can stop monitoring by closing the app
- No PII (Personally Identifiable Information) is collected

### Performance
- Location updates are throttled to 100 meters minimum distance
- Backend queries are limited to recent incidents (default: 24 hours)
- Local caching prevents redundant API calls
- Maximum radius limited to 10km to optimize query performance

## Testing

### Backend Tests

Run backend tests:
```bash
cd backend/safezone_backend
python manage.py test scoring
```

All scoring tests pass, including:
- User profile creation
- Report points awarded
- Confirmation points
- Duplicate confirmation prevention
- Tier progression
- Badge earning

### Manual Testing

1. **Test proximity detection**:
   - Create a test incident at a known location
   - Move device to within 500m of the incident
   - Verify confirmation dialog appears

2. **Test confirmation**:
   - Click "Yes, Confirm" in the dialog
   - Verify result dialog shows correct points
   - Check user profile shows updated points

3. **Test duplicate prevention**:
   - Try to confirm the same incident again
   - Verify dialog doesn't appear again
   - Verify backend returns error if API called directly

4. **Test tier upgrade**:
   - Confirm multiple incidents to reach tier threshold
   - Verify tier upgrade notification appears

## Future Enhancements

1. **Push notifications**: Send push notification when user approaches incident
2. **Configurable radius**: Let users adjust detection radius in settings
3. **Incident expiry**: Remove prompts for old incidents after certain time
4. **Rich feedback**: Allow users to add comments or photos when confirming
5. **Analytics**: Track confirmation accuracy and incident resolution
6. **Offline support**: Queue confirmations when offline, sync when online

## Troubleshooting

### Issue: Dialogs not appearing

**Solution**: 
- Check location permissions are granted
- Verify `IncidentProximityService` is initialized in home screen
- Check logs for error messages

### Issue: Duplicate prompts appearing

**Solution**:
- Clear prompted incidents cache: `_proximityService.clearPromptedIncidents()`
- Check SharedPreferences for `prompted_incidents` key

### Issue: Backend 400 error

**Solution**:
- Verify device_id is being passed correctly
- Check latitude/longitude values are valid
- Ensure backend is running and accessible

## API Documentation

### Nearby Incidents Endpoint

**URL**: `POST /api/scoring/incidents/nearby/`

**Headers**:
```
Content-Type: application/json
```

**Request Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| latitude | float | Yes | User's latitude |
| longitude | float | Yes | User's longitude |
| device_id | string | Yes | User's device identifier |
| radius_km | float | No | Detection radius (default: 0.5, max: 10) |
| hours | int | No | Time window in hours (default: 24) |

**Success Response (200)**:
```json
{
  "count": 2,
  "incidents": [...]
}
```

**Error Responses**:
- **400 Bad Request**: Missing or invalid parameters
- **500 Internal Server Error**: Server error

## Dependencies

### Frontend
- `geolocator`: ^13.0.2 - Location services
- `shared_preferences`: ^2.3.4 - Local storage
- `device_info_plus`: ^11.2.0 - Device identification
- `http`: For API calls
- `shadcn_ui`: UI components

### Backend
- Django REST Framework
- `alerts.utils.haversine_distance` - Distance calculation
- Existing scoring models and serializers

## Credits

Implemented as part of the SafeZone incident confirmation and scoring system.
