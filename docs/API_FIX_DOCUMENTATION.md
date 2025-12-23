# Fix for Flutter API Communication Issues

## Problem
The Flutter frontend was experiencing 400 errors and connection failures when communicating with the Django backend API. 

## Root Cause
The application was using a hardcoded `http://127.0.0.1:8000` as the base URL for all API requests. This works fine for iOS simulators, web, and desktop development, but **fails on Android emulators** because:

- On Android emulators, `127.0.0.1` refers to the emulator's own localhost, not the host machine
- Android emulators require `10.0.2.2` to reach the host machine's localhost
- This caused all API requests from Android devices/emulators to fail

## Solution
Created a centralized API configuration system that automatically detects the platform and uses the appropriate base URL:

### Changes Made

1. **Created `/frontend/lib/utils/api_config.dart`**
   - New utility class `ApiConfig` that provides platform-aware base URL
   - Automatically returns `http://10.0.2.2:8000` for Android
   - Returns `http://127.0.0.1:8000` for iOS, web, and desktop
   - Supports production URLs via environment variables

2. **Updated all API service initializations** to use `ApiConfig.getBaseUrl()`:
   - `frontend/lib/bootstrap.dart` - Firebase device registration
   - `frontend/lib/app/view/app.dart` - Main app API services
   - `frontend/lib/map/view/map_screen.dart` - Incident and WebSocket services
   - `frontend/lib/alerts/view/alerts_screen.dart` - Alerts API service
   - `frontend/lib/emergency_services/services/emergency_service_api_service.dart` - Emergency services

### Platform Behavior

| Platform | Development URL | Production URL |
|----------|----------------|----------------|
| Android Emulator | `http://10.0.2.2:8000` | From `API_BASE_URL` env var |
| iOS Simulator | `http://127.0.0.1:8000` | From `API_BASE_URL` env var |
| Web | `http://127.0.0.1:8000` | From `API_BASE_URL` env var |
| Desktop | `http://127.0.0.1:8000` | From `API_BASE_URL` env var |

## Testing
To test the fix:

1. **Backend Setup**:
   ```bash
   cd backend/safezone_backend
   pip install -r requirements.txt
   python manage.py migrate
   python manage.py runserver 0.0.0.0:8000
   ```

2. **Test API manually**:
   ```bash
   # Should return 200 OK with empty results
   curl http://127.0.0.1:8000/api/incidents/
   
   # Should create incident with 201 Created
   curl -X POST http://127.0.0.1:8000/api/incidents/ \
     -H "Content-Type: application/json" \
     -d '{"category":"theft","latitude":37.7749,"longitude":-122.4194,"title":"Test","description":"Test","notify_nearby":false}'
   ```

3. **Flutter App**:
   - On Android emulator: App will connect to `http://10.0.2.2:8000`
   - On iOS simulator: App will connect to `http://127.0.0.1:8000`
   - Both should now successfully communicate with the backend

## Production Deployment
When deploying to production, set the `API_BASE_URL` environment variable during the build:

```bash
flutter build apk --dart-define=API_BASE_URL=https://api.your-domain.com
flutter build ios --dart-define=API_BASE_URL=https://api.your-domain.com
```

## Future Enhancements
- Consider adding a settings UI to allow users to configure a custom API URL
- Add connection status indicators in the app
- Implement better error messages for API connection failures
