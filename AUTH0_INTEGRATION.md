# Auth0 Integration Guide for SafeZone

This guide explains how to set up Auth0 authentication for both the backend API and mobile frontend.

## Overview

SafeZone uses Auth0 for user authentication, providing:
- Secure JWT token-based authentication
- Universal Login for mobile apps
- Token refresh capabilities
- Secure token storage using Flutter Secure Storage
- Automatic token attachment to API requests

## Architecture

### Backend (Django)
- **Auth0 JWT verification**: Custom authentication class validates JWT tokens from Auth0
- **Protected routes**: API endpoints require valid JWT tokens for write operations
- **User identification**: Auth0 `sub` (subject) used as user identifier

### Frontend (Flutter)
- **Auth0 Flutter SDK**: Native Auth0 integration
- **Secure token storage**: Tokens stored in device keychain/keystore
- **Authenticated HTTP client**: Automatically attaches JWT to API requests
- **State management**: BLoC pattern for authentication state

## Prerequisites

1. **Auth0 Account**: Sign up at [auth0.com](https://auth0.com)
2. **Auth0 Application**: Create a Native application in Auth0 dashboard
3. **Auth0 API**: Create an API in Auth0 dashboard for the backend

## Backend Setup

### 1. Create Auth0 API

1. Go to [Auth0 Dashboard](https://manage.auth0.com)
2. Navigate to **Applications → APIs**
3. Click **Create API**
4. Fill in:
   - **Name**: SafeZone API
   - **Identifier**: `https://safezone-api` (or your preferred identifier)
   - **Signing Algorithm**: RS256
5. Click **Create**

### 2. Configure Environment Variables

Create or update `.env` file in `backend/safezone_backend/`:

```bash
# Auth0 Configuration
AUTH0_DOMAIN=your-tenant.auth0.com
AUTH0_AUDIENCE=https://safezone-api

# Other settings
FIELD_ENCRYPTION_KEY=<generate-using-cryptography.fernet.Fernet.generate_key()>
DJANGO_SECRET_KEY=<your-django-secret-key>
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2
```

**Generate encryption key:**
```bash
python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

### 3. Install Dependencies

```bash
cd backend/safezone_backend
pip install -r requirements.txt
```

### 4. Verify Setup

```bash
python manage.py check
```

## Frontend Setup

### 1. Create Auth0 Application

1. Go to [Auth0 Dashboard](https://manage.auth0.com)
2. Navigate to **Applications → Applications**
3. Click **Create Application**
4. Fill in:
   - **Name**: SafeZone Mobile
   - **Application Type**: Native
5. Click **Create**

### 2. Configure Application Settings

In your Auth0 application settings:

#### Allowed Callback URLs
```
com.safezone.app://YOUR_AUTH0_DOMAIN/ios/com.safezone.app/callback,
com.safezone.app://YOUR_AUTH0_DOMAIN/android/com.safezone.app/callback
```

#### Allowed Logout URLs
```
com.safezone.app://YOUR_AUTH0_DOMAIN/ios/com.safezone.app/callback,
com.safezone.app://YOUR_AUTH0_DOMAIN/android/com.safezone.app/callback
```

#### Allowed Web Origins
```
com.safezone.app
```

### 3. Update Flutter Configuration

Update `frontend/lib/authentication/config/auth0_config.dart`:

```dart
class Auth0Config {
  const Auth0Config._();

  static const String domain = 'your-tenant.auth0.com';
  static const String clientId = 'your-client-id-from-auth0';
  static const String audience = 'https://safezone-api';

  static const List<String> scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];
}
```

Or use environment variables during build:

```bash
flutter run --dart-define=AUTH0_DOMAIN=your-tenant.auth0.com \
            --dart-define=AUTH0_CLIENT_ID=your-client-id \
            --dart-define=AUTH0_AUDIENCE=https://safezone-api
```

### 4. Configure Platform-Specific Settings

#### Android

Update `frontend/android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
  <application ...>
    <activity
      android:name="com.auth0.android.provider.RedirectActivity"
      android:exported="true">
      <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
          android:scheme="com.safezone.app"
          android:host="YOUR_AUTH0_DOMAIN"
          android:pathPrefix="/android/com.safezone.app/callback" />
      </intent-filter>
    </activity>
  </application>
</manifest>
```

#### iOS

Update `frontend/ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.safezone.app</string>
    </array>
  </dict>
</array>
```

### 5. Install Dependencies

```bash
cd frontend
flutter pub get
```

## Usage

### Backend - Protected Endpoints

Endpoints automatically require authentication based on permission classes:

```python
# Require authentication for all operations
from rest_framework.permissions import IsAuthenticated

class MyView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticated]
    # ...

# Allow read without auth, require auth for write
from rest_framework.permissions import IsAuthenticatedOrReadOnly

class MyView(generics.ListCreateAPIView):
    permission_classes = [IsAuthenticatedOrReadOnly]
    # ...
```

Access authenticated user:
```python
def perform_create(self, serializer):
    # request.user contains Auth0User with .id, .sub, .email
    serializer.save(user_id=self.request.user.id)
```

### Frontend - Using Authentication

#### Initialize Auth0Service

```dart
import 'package:safe_zone/authentication/authentication.dart';

final auth0Service = Auth0Service(
  domain: Auth0Config.domain,
  clientId: Auth0Config.clientId,
);
```

#### Provide AuthenticationCubit

```dart
BlocProvider(
  create: (context) => AuthenticationCubit(
    auth0Service: auth0Service,
  )..checkAuthentication(),
  child: MyApp(),
)
```

#### Make Authenticated API Calls

```dart
import 'package:safe_zone/authentication/authentication.dart';

final apiClient = ApiClient(
  auth0Service: auth0Service,
  baseUrl: 'http://localhost:8000',
);

// Tokens are automatically attached
final response = await apiClient.post(
  '/api/incidents/',
  body: {
    'title': 'Incident Title',
    'category': 'theft',
    // ...
  },
);
```

#### Check Authentication State

```dart
BlocBuilder<AuthenticationCubit, AuthenticationState>(
  builder: (context, state) {
    if (state is AuthenticationAuthenticated) {
      return HomePage();
    } else if (state is AuthenticationUnauthenticated) {
      return LoginPage();
    } else if (state is AuthenticationLoading) {
      return LoadingPage();
    } else if (state is AuthenticationError) {
      return ErrorPage(message: state.message);
    }
    return SplashScreen();
  },
)
```

## API Endpoints Protected

The following endpoints now require authentication:

### User Settings
- `POST /api/devices/register/` - Register device (requires auth)
- `GET /api/safe-zones/` - List safe zones (requires auth)
- `POST /api/safe-zones/` - Create safe zone (requires auth)
- `PUT/PATCH /api/safe-zones/{id}/` - Update safe zone (requires auth)
- `DELETE /api/safe-zones/{id}/` - Delete safe zone (requires auth)
- `GET /api/preferences/{device_id}/` - Get preferences (requires auth)
- `PUT/PATCH /api/preferences/{device_id}/` - Update preferences (requires auth)

### Incident Reporting
- `POST /api/incidents/` - Create incident (requires auth)
- `GET /api/incidents/` - List incidents (no auth required)
- `GET /api/incidents/{id}/` - Get incident (no auth required)

## Testing

### Backend Testing

Test authentication with curl:

```bash
# Get token from Auth0 (use your Auth0 test token)
TOKEN="your-auth0-jwt-token"

# Test authenticated request
curl -H "Authorization: Bearer $TOKEN" \
     -H "Content-Type: application/json" \
     -X POST \
     -d '{"title":"Test","category":"theft","latitude":0,"longitude":0}' \
     http://localhost:8000/api/incidents/
```

### Frontend Testing

1. Run the app: `flutter run`
2. Complete onboarding screens
3. Click "Sign In with Auth0"
4. Complete Auth0 Universal Login
5. Verify redirect back to app
6. Check that authenticated state is maintained
7. Test API calls (incident reporting, user settings)
8. Test logout

## Troubleshooting

### Backend Issues

**"FIELD_ENCRYPTION_KEY defined incorrectly"**
- Generate proper Fernet key: `python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"`

**"Unable to fetch Auth0 public keys"**
- Verify AUTH0_DOMAIN is set correctly
- Check network connectivity
- Ensure AUTH0_DOMAIN doesn't include https://

**"Token verification failed"**
- Verify AUTH0_AUDIENCE matches your API identifier
- Check token is not expired
- Ensure RS256 signing algorithm is used

### Frontend Issues

**"Login failed"**
- Verify callback URLs are configured in Auth0
- Check clientId and domain are correct
- Ensure app bundle ID matches Auth0 configuration

**"API calls return 401"**
- Check token is being stored correctly
- Verify token is being attached to requests
- Check backend AUTH0_AUDIENCE matches frontend

**"Token not found"**
- Ensure login completed successfully
- Check secure storage permissions

## Security Considerations

1. **Never commit credentials**: Use environment variables
2. **Use HTTPS in production**: Set `SECURE_SSL_REDIRECT=True`
3. **Rotate secrets regularly**: Update encryption keys periodically
4. **Implement rate limiting**: Protect against brute force attacks
5. **Monitor token usage**: Track suspicious authentication patterns
6. **Use short token expiration**: Default is typically 1 hour
7. **Implement refresh tokens**: Already supported by Auth0Service

## Additional Resources

- [Auth0 Documentation](https://auth0.com/docs)
- [Auth0 Flutter SDK](https://github.com/auth0/auth0-flutter)
- [Django REST Framework Authentication](https://www.django-rest-framework.org/api-guide/authentication/)
- [JWT.io](https://jwt.io) - Debug JWT tokens

## Support

For issues with Auth0 integration:
1. Check Auth0 logs in dashboard
2. Review Django logs for backend issues
3. Use Flutter DevTools for frontend debugging
4. Check this documentation for configuration steps
