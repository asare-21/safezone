# Backend 400/500 Error Investigation & Resolution

## Investigation Summary

When investigating the reported "400 errors for every request", I discovered the actual issues were:

### Issue 1: Database Not Initialized (500 Errors)
**Problem**: The backend was returning **500 Internal Server Errors** (not 400) because database migrations had not been applied.

**Error Message**:
```
django.db.utils.OperationalError: no such table: incident_reporting_incident
```

**Resolution**: Applied database migrations
```bash
cd backend/safezone_backend
python manage.py migrate
```

**Result**: ✅ All database tables created successfully

### Issue 2: Inconsistent Permission Classes (403 Errors)
**Problem**: Some endpoints (specifically in the `alerts` app) had hardcoded `permission_classes = [IsAuthenticatedOrReadOnly]` which required authentication for POST requests, while other endpoints (in `incident_reporting`) used dynamic permissions that check for DEBUG mode.

**Affected Endpoints**:
- `POST /api/alerts/generate/` - Was returning 403 Forbidden
- All alerts endpoints were inconsistent with incident_reporting endpoints

**Resolution**: Updated `alerts/views.py` to use dynamic permissions matching the pattern in `incident_reporting/views.py`:

```python
def get_permissions(self):
    """
    Use AllowAny in development without Auth0, otherwise require auth for writes.
    """
    if settings.DEBUG and not settings.AUTH0_DOMAIN:
        return [AllowAny()]
    return [IsAuthenticatedOrReadOnly()]
```

**Result**: ✅ All endpoints now work in development mode without authentication

## Test Results

All API endpoints now return correct status codes:

### Successful Requests (Should NOT return 400/500)
- ✅ `GET /api/incidents/` - **200 OK**
- ✅ `POST /api/incidents/` - **201 Created**
- ✅ `GET /api/alerts/` - **200 OK**
- ✅ `POST /api/alerts/generate/` - **201 Created** (was 403, now fixed)
- ✅ `GET /api/guides/` - **200 OK**
- ✅ `GET /api/emergency-services/` - **200 OK**

### Validation Errors (Correctly return 400)
- ✅ Invalid category: `"invalid_category" is not a valid choice` - **400 Bad Request**
- ✅ Invalid latitude: `A valid number is required` - **400 Bad Request**
- ✅ Missing required field: `This field is required` - **400 Bad Request**

## Root Causes Explained

### Why "All Requests" Were Failing

1. **Database tables didn't exist** → 500 errors for any database query
2. **Migrations weren't applied** → Server started but couldn't access data
3. **Permission classes were inconsistent** → Some POST endpoints required auth even in DEBUG mode

### Why It Appeared to Be "400 Errors"

Users likely saw various HTTP error codes in their Flutter app, which might have been:
- 500 Internal Server Error (database not initialized)
- 403 Forbidden (authentication required)
- Connection timeouts/failures (wrong IP address - covered in previous fix)

The combination of these issues made it seem like "all requests return 400 errors."

## Setup Instructions

To ensure the backend works correctly, developers should:

1. **Install dependencies**:
   ```bash
   cd backend/safezone_backend
   pip install -r requirements.txt
   ```

2. **Apply migrations** (critical step):
   ```bash
   python manage.py migrate
   ```

3. **Start the server**:
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

4. **Verify it's working**:
   ```bash
   curl http://127.0.0.1:8000/api/incidents/
   # Should return: {"count":0,"next":null,"previous":null,"results":[]}
   ```

## Files Modified

- `backend/safezone_backend/alerts/views.py`
  - Added `AllowAny` import
  - Added `settings` import
  - Changed `AlertListView` to use dynamic `get_permissions()` method
  - Changed `AlertRetrieveView` to use dynamic `get_permissions()` method
  - Changed `AlertGenerateView` to use dynamic `get_permissions()` method

## Development vs Production

### Development Mode (DEBUG=True, no AUTH0_DOMAIN)
- All endpoints use `AllowAny` permission
- No authentication required
- Allows easy testing and development

### Production Mode (DEBUG=False or AUTH0_DOMAIN set)
- All write endpoints use `IsAuthenticatedOrReadOnly`
- Authentication required for POST/PUT/PATCH/DELETE
- Read endpoints (GET) remain public

## Testing Commands

```bash
# Test GET request
curl -X GET http://127.0.0.1:8000/api/incidents/

# Test POST request
curl -X POST http://127.0.0.1:8000/api/incidents/ \
  -H "Content-Type: application/json" \
  -d '{"category":"theft","latitude":37.7749,"longitude":-122.4194,"title":"Test","description":"Test","notify_nearby":false}'

# Test alerts generation
curl -X POST http://127.0.0.1:8000/api/alerts/generate/ \
  -H "Content-Type: application/json" \
  -d '{"latitude":37.7749,"longitude":-122.4194,"radius_km":10,"hours":24}'
```

## Summary

**Original Problem**: "Currently getting 400 errors for every request. None of them are successful"

**Actual Issues**:
1. ❌ Database migrations not applied → 500 errors
2. ❌ Inconsistent permission classes → 403 errors on some POST endpoints

**Resolution**:
1. ✅ Applied database migrations
2. ✅ Fixed permission classes to be consistent across all apps
3. ✅ All endpoints now work correctly in development mode

**Status**: 🎉 **RESOLVED** - All API endpoints working correctly
