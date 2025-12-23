# Guides Backend and Frontend Integration

## Overview

The guides feature provides a dynamic, database-backed system for displaying safety guide content in the SafeZone app. Content is stored in the Django backend and fetched by the Flutter frontend.

## Backend Implementation

### Models

**Guide Model** (`backend/safezone_backend/guides/models.py`)
- `section`: Section category (how_it_works, reporting, alerts, etc.)
- `title`: Guide title
- `content`: Guide content/description
- `icon`: Icon identifier for the UI
- `order`: Display order within section
- `is_active`: Whether the guide is currently active
- Created/updated timestamps

### API Endpoints

**List Guides**
```
GET /api/guides/
```
Returns all active guides ordered by section and order.

**Retrieve Guide**
```
GET /api/guides/<id>/
```
Returns a specific guide by ID.

### Admin Interface

Guides can be managed through the Django admin interface at `/admin/`:
1. Navigate to "Guides"
2. Add, edit, or delete guide entries
3. Toggle `is_active` to show/hide guides
4. Use `order` field to control display order within sections

### Populating Initial Data

To populate the database with initial guide content:
```bash
cd backend/safezone_backend
python manage.py shell < guides/populate_guides.py
```

## Frontend Implementation

### Architecture

The frontend uses BLoC/Cubit pattern for state management:

**Components:**
- `Guide` model - Data model matching backend structure
- `GuideApiService` - HTTP service for fetching guides
- `GuideCubit` - State management for guides
- `GuideState` - State classes (Initial, Loading, Loaded, Error)
- `GuideScreen` - UI displaying guides

### Guide Model

Located at `frontend/lib/guide/models/guide_model.dart`:
- Maps backend Guide model to Dart
- Includes `GuideSection` enum for section types
- Provides JSON serialization

### API Service

Located at `frontend/lib/guide/services/guide_api_service.dart`:
- `getGuides()` - Fetch all guides
- `getGuide(id)` - Fetch specific guide
- Configured with backend base URL

### State Management

**GuideCubit** (`frontend/lib/guide/cubit/guide_cubit.dart`):
- `loadGuides()` - Initial load
- `refreshGuides()` - Refresh data
- Groups guides by section for display

**States:**
- `GuideInitial` - Before first load
- `GuideLoading` - Loading from API
- `GuideLoaded` - Successfully loaded with data
- `GuideError` - Error occurred

### UI Features

The `GuideScreen` displays:
- Welcome card
- Dynamically loaded guide sections from backend
- Pull-to-refresh functionality
- Loading and error states
- Retry button on error
- Refresh button in header

### Configuration

The GuideApiService is configured in `lib/app/view/app.dart`:

```dart
final guideApiService = GuideApiService(
  baseUrl: 'http://10.0.2.2:8000', // Android emulator
  // baseUrl: 'http://localhost:8000', // iOS simulator / web
);
```

For physical devices, use your computer's local network IP:
```dart
baseUrl: 'http://192.168.1.XXX:8000',
```

## Testing

### Backend Tests

Run Django tests:
```bash
cd backend/safezone_backend
python manage.py test guides
```

### Frontend Tests

Run Flutter tests:
```bash
cd frontend
flutter test test/guide/
```

Tests use mocked GuideCubit to verify:
- UI renders correctly
- Loading states display
- Error states display with retry
- Loaded state shows guides
- User interactions work (refresh, retry)

## Usage

### Adding New Guide Content

1. Access Django admin at `http://localhost:8000/admin/`
2. Navigate to Guides section
3. Click "Add Guide"
4. Fill in:
   - Section (choose from dropdown)
   - Title
   - Content (supports newlines for lists)
   - Icon (optional, must match available icons)
   - Order (lower numbers appear first)
   - Is active (checked to display)
5. Save

The new guide will immediately appear in the app on next refresh.

### Updating Existing Content

1. Access Django admin
2. Click on the guide to edit
3. Make changes
4. Save

Changes appear in the app after refresh.

### Available Icons

Icons are mapped in `GuideScreen._getIconForGuide()`:
- `shield` → Alternate Shield
- `map_marker` → Map Marker
- `map` → Map
- `award` → Award
- `lock` → Lock
- `user_secret` → User Secret
- `eye` → Eye
- `users` → Users
- `share` → Share
- `check_circle` → Check Circle
- `lightbulb` → Lightbulb
- `phone_volume` → Phone Volume
- `cog` → Cog

To add new icons, update the `_getIconForGuide()` method.

## Troubleshooting

### Backend Issues

**Guides not appearing:**
- Check `is_active` is set to `true` in admin
- Verify Django server is running
- Check `/api/guides/` endpoint returns data

**Database errors:**
- Run migrations: `python manage.py migrate guides`
- Check database file exists: `db.sqlite3`

### Frontend Issues

**Loading forever:**
- Check backend URL configuration
- Verify Django server is accessible
- Check network connectivity

**Error state:**
- Check console for detailed error messages
- Verify API endpoint is correct
- Check CORS settings if using web

**Content not updating:**
- Use pull-to-refresh gesture
- Tap refresh icon in header
- Restart app

## Migration Notes

The old `GuideScreen` had hardcoded content. The new implementation:
- ✅ Maintains the same visual design
- ✅ Loads content dynamically from backend
- ✅ Supports easy content updates via admin
- ✅ Includes loading and error states
- ✅ Supports pull-to-refresh
- ✅ Properly tested with mocks

All existing guide content has been migrated to the database via the `populate_guides.py` script.
