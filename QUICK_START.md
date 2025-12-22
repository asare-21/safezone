# Quick Start Guide - SafeZone Backend & Frontend Integration

## 🚀 Getting Started in 5 Minutes

### Step 1: Start the Backend (Terminal 1)

```bash
cd backend/safezone_backend

# Install dependencies
pip install django==4.2.23 djangorestframework django-cors-headers

# Run migrations
python manage.py migrate

# Populate initial data
python manage.py populate_guides
python manage.py populate_emergency_services

# Start server
python manage.py runserver 8000
```

✅ Backend API now running at `http://localhost:8000/api/incidents/`

### Step 2: Configure Frontend

Edit `frontend/lib/map/view/map_screen.dart` line ~42:

**For Android Emulator:**
```dart
baseUrl: 'http://10.0.2.2:8000',
```

**For iOS Simulator:**
```dart
baseUrl: 'http://localhost:8000',
```

**For Physical Device:**
```dart
baseUrl: 'http://YOUR_COMPUTER_IP:8000',  // e.g., 'http://192.168.1.100:8000'
```

Find your IP:
- **macOS/Linux:** `ifconfig | grep "inet "`
- **Windows:** `ipconfig`

### Step 3: Run the Frontend (Terminal 2)

```bash
cd frontend

# Install dependencies
flutter pub get

# Run app
flutter run
```

✅ App now loads incidents from backend and can create new ones!

## 📱 How It Works

1. **App Starts** → Fetches incidents from `GET /api/incidents/`
2. **User Reports Incident** → Sends to `POST /api/incidents/`
3. **Incidents Persist** → Stored in SQLite database
4. **App Restarts** → Incidents reload from database

## 🧪 Quick Test

```bash
# Test API is working
curl http://localhost:8000/api/incidents/

# Create test incident
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

## 📚 Documentation

- **Full Setup:** `BACKEND_INTEGRATION.md`
- **Test Results:** `INTEGRATION_TEST_RESULTS.md`
- **Summary:** `FINAL_SUMMARY.md`

## ⚠️ Troubleshooting

**"Connection refused"**
- ✅ Check backend is running: `curl http://localhost:8000/api/incidents/`
- ✅ Android emulator must use `10.0.2.2` not `localhost`
- ✅ Physical device must be on same WiFi

**"Failed to load incidents"**
- ✅ Check console for error details
- ✅ App falls back to mock data automatically
- ✅ Verify firewall isn't blocking port 8000

**Incidents not persisting**
- ✅ Check migrations ran: `python manage.py migrate`
- ✅ Database file exists: `ls backend/safezone_backend/db.sqlite3`

## 🎯 API Endpoints

- `GET /api/incidents/` - List all incidents
- `POST /api/incidents/` - Create incident
- `GET /api/incidents/<id>/` - Get specific incident
- `GET /admin/` - Django admin (create superuser first)

## 📊 Features

✅ 18 incident categories  
✅ GPS location tracking  
✅ Real-time map updates  
✅ Offline fallback  
✅ Error handling  
✅ User feedback  
✅ Data persistence  

## 🔒 Security Note

Current CORS allows all origins (development only).  
For production, update `backend/safezone_backend/safezone_backend/settings.py`:

```python
CORS_ALLOWED_ORIGINS = ['https://yourdomain.com']
CORS_ALLOW_ALL_ORIGINS = False  # Change this!
```

## 🎉 You're Done!

The backend and frontend are now fully integrated. Report incidents from the app and see them persist across restarts!

---

**Need help?** Check the detailed documentation in `BACKEND_INTEGRATION.md`
