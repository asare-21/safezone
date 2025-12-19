# Backend and Frontend Integration

This document describes how the SafeZone frontend (Flutter) connects to the backend (Django) for incident reporting.

## Overview

The incident reporting system now uses a REST API to persist incidents to a Django backend with SQLite database. The frontend communicates with the backend using HTTP requests.

## Backend Setup

### 1. Install Dependencies

```bash
cd backend/safezone_backend
pip install django==4.2.23 djangorestframework django-cors-headers
```

### 2. Run Migrations

```bash
python manage.py migrate
```

### 3. Start the Development Server

```bash
python manage.py runserver 8000
```

The API will be available at `http://localhost:8000/api/incidents/`

### 4. (Optional) Create Admin User

To access the Django admin interface:

```bash
python manage.py createsuperuser
```

Then visit `http://localhost:8000/admin/` to manage incidents.

## Frontend Setup

### 1. Install Dependencies

```bash
cd frontend
flutter pub get
```

### 2. Configure Backend URL

Edit `lib/map/view/map_screen.dart` and update the API base URL:

**For Android Emulator:**
```dart
_apiService = IncidentApiService(
  baseUrl: 'http://10.0.2.2:8000',  // Android emulator uses 10.0.2.2 for localhost
);
```

**For iOS Simulator:**
```dart
_apiService = IncidentApiService(
  baseUrl: 'http://localhost:8000',  // iOS simulator can use localhost
);
```

**For Physical Device:**
Replace with your computer's IP address on the local network:
```dart
_apiService = IncidentApiService(
  baseUrl: 'http://192.168.1.XXX:8000',  // Your computer's local IP
);
```

To find your IP address:
- **macOS/Linux:** Run `ifconfig` or `ip addr`
- **Windows:** Run `ipconfig`

### 3. Run the App

```bash
flutter run
```

## API Endpoints

### GET /api/incidents/
Retrieve all incidents (paginated, 100 per page).

**Response:**
```json
{
  "count": 2,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "category": "theft",
      "latitude": 5.6037,
      "longitude": -0.187,
      "title": "Theft",
      "description": "A theft has been reported in this area",
      "timestamp": "2025-12-19T14:36:38.187610Z",
      "confirmed_by": 1,
      "notify_nearby": true
    }
  ]
}
```

### POST /api/incidents/
Create a new incident report.

**Request:**
```json
{
  "category": "theft",
  "latitude": 5.6037,
  "longitude": -0.187,
  "title": "Theft",
  "description": "A theft has been reported in this area",
  "notify_nearby": true
}
```

**Response:**
```json
{
  "category": "theft",
  "latitude": 5.6037,
  "longitude": -0.187,
  "title": "Theft",
  "description": "A theft has been reported in this area",
  "notify_nearby": true
}
```

### GET /api/incidents/<id>/
Retrieve a specific incident by ID.

## Architecture

### Backend (Django)

**Model:** `incident_reporting/models.py`
- Stores incidents with category, location (lat/lng), title, description, timestamp
- 18 comprehensive incident categories matching the frontend

**Serializers:** `incident_reporting/serializers.py`
- `IncidentSerializer`: For reading incidents
- `IncidentCreateSerializer`: For creating incidents with validation

**Views:** `incident_reporting/views.py`
- `IncidentListCreateView`: List all incidents or create new one
- `IncidentRetrieveView`: Get a specific incident by ID

**URLs:** Configured in `safezone_backend/urls.py`
- `/api/incidents/` - List/Create
- `/api/incidents/<id>/` - Retrieve

### Frontend (Flutter)

**API Service:** `lib/incident_report/services/incident_api_service.dart`
- Handles all HTTP communication with the backend
- Converts between JSON and Dart models
- Error handling for network failures

**Integration:** `lib/map/view/map_screen.dart`
- Uses `IncidentApiService` to fetch incidents on load
- Submits new incidents via API
- Falls back to mock data if API is unavailable
- Shows error messages for failed API calls

## Testing the Integration

### 1. Start the Backend

```bash
cd backend/safezone_backend
python manage.py runserver 8000
```

### 2. Test API with curl

```bash
# Get all incidents
curl http://localhost:8000/api/incidents/

# Create a test incident
curl -X POST http://localhost:8000/api/incidents/ \
  -H "Content-Type: application/json" \
  -d '{
    "category": "theft",
    "latitude": 5.6037,
    "longitude": -0.1870,
    "title": "Test Incident",
    "description": "Testing the API",
    "notify_nearby": true
  }'
```

### 3. Run the Frontend

```bash
cd frontend
flutter run
```

The app should:
1. Load existing incidents from the backend on startup
2. Display them on the map
3. Submit new incidents to the backend when you report one
4. Show success/error messages based on API response

## Development Notes

### CORS Configuration

The backend is configured to allow all origins for development:
```python
CORS_ALLOW_ALL_ORIGINS = True
```

**⚠️ Important:** In production, restrict this to specific domains.

### Fallback to Mock Data

If the API is unavailable (e.g., backend not running), the frontend will:
1. Show an error in the console
2. Fall back to generating mock incidents near your location
3. Allow you to continue using the app with local data only

### Network Security (Android)

For Android apps to connect to HTTP (not HTTPS) servers during development, ensure your `AndroidManifest.xml` has:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

This is typically already configured for development builds.

## Troubleshooting

### "Failed to load incidents from API"

1. Check if the backend server is running: `curl http://localhost:8000/api/incidents/`
2. Verify the `baseUrl` in `map_screen.dart` matches your setup
3. For Android emulator, ensure you're using `10.0.2.2` not `localhost`
4. Check your firewall settings

### "Connection refused"

1. Make sure Django is running on port 8000
2. Check if your computer's firewall is blocking connections
3. For physical devices, ensure they're on the same WiFi network

### Incidents not persisting

1. Check if migrations were run: `python manage.py migrate`
2. Check the database file exists: `ls backend/safezone_backend/db.sqlite3`
3. Check Django admin to verify incidents are saved

## Future Enhancements

- [ ] User authentication
- [ ] Image upload for incidents
- [ ] Real-time updates via WebSockets
- [ ] Geospatial queries for nearby incidents
- [ ] PostgreSQL with PostGIS for production
- [ ] Push notifications when new incidents are reported nearby
