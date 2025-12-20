# Alerts System Implementation Guide

## Overview

The SafeZone alerts system provides real-time proximity-based safety alerts to users. Alerts are automatically generated from reported incidents and delivered with near-real-time updates (30-second refresh interval).

## Architecture

### Backend (Django)

#### Models

**Alert Model** (`backend/safezone_backend/alerts/models.py`):
```python
class Alert(models.Model):
    incident = ForeignKey(Incident)  # Source incident
    alert_type = CharField           # highRisk, theft, eventCrowd, trafficCleared
    severity = CharField             # high, medium, low, info
    title = CharField
    location = CharField
    timestamp = DateTimeField
    confirmed_by = IntegerField
    distance_meters = FloatField
```

**Key Features:**
- Automatic severity mapping from incident categories
- Support for multiple alert types
- Distance tracking from user location
- Timestamp-based ordering (newest first)

#### API Endpoints

1. **List Alerts** - `GET /api/alerts/`
   - Query Parameters:
     - `severity`: Filter by severity (high, medium, low, info)
     - `alert_type`: Filter by type
     - `hours`: Time range (default: 24)
     - `latitude`, `longitude`: User location for proximity filtering
     - `radius_km`: Search radius (default: 10, max: 50)
   
2. **Retrieve Alert** - `GET /api/alerts/<id>/`
   - Returns full alert details with nested incident data

3. **Generate Alerts** - `POST /api/alerts/generate/`
   - Body: `{latitude, longitude, radius_km, hours}`
   - Generates new alerts from nearby incidents
   - Returns list of newly created alerts

#### Severity Mapping

Incidents are automatically mapped to alert severities:

| Incident Category | Alert Severity |
|------------------|----------------|
| assault, theft, fire, weaponSighting, medicalEmergency, naturalDisaster | high |
| harassment, suspicious, vandalism, drugActivity, roadHazard, accident | medium |
| trespassing, lighting, animalDanger | low |
| powerOutage, waterIssue, noise | info |

### Frontend (Flutter)

#### State Management

**AlertsCubit** (`frontend/lib/alerts/cubit/alerts_cubit.dart`):
- Manages alert data and API communication
- States: Initial, Loading, Loaded, Error
- Auto-refresh every 30 seconds
- Pull-to-refresh support

**States:**
```dart
- AlertsInitial: Before any data loaded
- AlertsLoading: Fetching alerts
- AlertsLoaded: Data loaded successfully
- AlertsError: Failed to load
```

#### API Service

**AlertApiService** (`frontend/lib/alerts/services/alert_api_service.dart`):
- HTTP client for alerts API
- Methods:
  - `getAlerts()`: Fetch with filters
  - `getAlert(id)`: Get single alert
  - `generateAlerts()`: Generate from nearby incidents

#### UI Components

**AlertsScreen** (`frontend/lib/alerts/view/alerts_screen.dart`):
- Real-time connection status indicator
- Auto-refresh with 30s interval
- Location-based filtering (10km radius)
- Pull-to-refresh capability
- Loading/error/empty states
- Filter chips (All, Critical, Recent, Nearby)

## Setup Instructions

### Backend Setup

1. **Install Dependencies:**
   ```bash
   cd backend/safezone_backend
   pip install -r requirements.txt
   ```

2. **Configure Environment:**
   Create `.env` file with:
   ```env
   DJANGO_SECRET_KEY=your-secret-key
   DJANGO_DEBUG=True
   DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2
   FIELD_ENCRYPTION_KEY=your-fernet-key
   ```

3. **Run Migrations:**
   ```bash
   python manage.py migrate
   ```

4. **Start Server:**
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

### Frontend Setup

1. **Configure Base URL:**
   The app automatically uses the correct URL:
   - Android emulator: `http://10.0.2.2:8000`
   - iOS simulator: `http://localhost:8000`
   - Production: Configure in `AlertsScreen`

2. **Run App:**
   ```bash
   cd frontend
   flutter run
   ```

## Testing

### Backend Tests

Run alert model tests:
```bash
cd backend/safezone_backend
python manage.py test alerts.tests.AlertModelTest
```

**Test Coverage:**
- Alert creation
- Alert generation from incidents
- Timestamp ordering
- Severity mapping
- String representation

### Manual Testing

1. **Create Test Incident:**
   ```python
   from incident_reporting.models import Incident
   Incident.objects.create(
       category='assault',
       latitude=37.7749,
       longitude=-122.4194,
       title='Test Incident',
       confirmed_by=1
   )
   ```

2. **Generate Alerts:**
   ```bash
   curl -X POST http://localhost:8000/api/alerts/generate/ \
     -H "Content-Type: application/json" \
     -d '{
       "latitude": 37.7749,
       "longitude": -122.4194,
       "radius_km": 10,
       "hours": 24
     }'
   ```

3. **List Alerts:**
   ```bash
   curl http://localhost:8000/api/alerts/
   ```

## Features

### Real-time Updates
- **Auto-refresh**: Every 30 seconds
- **Pull-to-refresh**: Manual refresh
- **Connection status**: Visual indicator

### Location-based Filtering
- GPS-based proximity detection
- Configurable radius (default: 10km, max: 50km)
- Haversine distance calculation

### Multi-level Filtering
- Severity: High, Medium, Low, Info
- Type: High Risk, Theft, Event Crowd, Traffic Cleared
- Time: Last hour, 24h, 7 days, all
- Location: Nearby (with GPS)

### User Experience
- Loading states with spinner
- Error states with retry
- Empty states with filter reset
- Smooth animations

## Performance Considerations

### Current Implementation
- **In-memory filtering**: For development/MVP
- **Haversine calculation**: Python-based distance calculation
- **Query optimization**: Select_related for incident data

### Production Recommendations
1. **Use PostGIS**: For geospatial queries at database level
2. **Add Caching**: Redis for frequently accessed alerts
3. **Pagination**: Implement cursor-based pagination
4. **Indexing**: Ensure proper database indexes
5. **WebSockets**: For true real-time updates (instead of polling)

## API Response Examples

### List Alerts
```json
{
  "count": 2,
  "results": [
    {
      "id": 1,
      "incident_id": 5,
      "incident_category": "assault",
      "incident_latitude": 37.7749,
      "incident_longitude": -122.4194,
      "alert_type": "highRisk",
      "severity": "high",
      "title": "Assault Reported Nearby",
      "location": "37.774900, -122.419400",
      "timestamp": "2025-12-20T22:30:00Z",
      "confirmed_by": 3,
      "distance_meters": 450.0,
      "time_ago": "5 mins ago"
    }
  ]
}
```

## Troubleshooting

### Backend Issues

**Migration Errors:**
```bash
python manage.py makemigrations alerts
python manage.py migrate alerts
```

**Import Errors:**
- Ensure all dependencies installed: `pip install -r requirements.txt`
- Check INSTALLED_APPS includes 'alerts'

### Frontend Issues

**Connection Refused:**
- Android: Use `10.0.2.2:8000` instead of `localhost`
- iOS: Use `localhost:8000`
- Ensure backend is running

**Location Permissions:**
- Check app has location permissions
- Handle denied permissions gracefully

## Future Enhancements

1. **WebSocket Support**: Real-time updates without polling
2. **Push Notifications**: FCM integration for background alerts
3. **Alert Prioritization**: Smart ranking based on severity and distance
4. **Historical Trends**: Analytics on alert patterns
5. **User Preferences**: Customizable alert types and severities
6. **Geofencing**: Automatic alerts when entering high-risk areas

## Security

- **Authentication**: Optional (IsAuthenticatedOrReadOnly)
- **Data Validation**: Input validation on all endpoints
- **Rate Limiting**: Recommended for production
- **SQL Injection**: Protected by Django ORM
- **XSS**: Sanitized output

**CodeQL Results**: ✅ No vulnerabilities found

## Monitoring

Recommended monitoring:
- Alert generation rate
- API response times
- Error rates
- User location permissions
- Auto-refresh success rate

## License

Part of SafeZone project - See main README for license information.
