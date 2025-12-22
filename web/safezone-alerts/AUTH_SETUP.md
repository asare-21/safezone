# Authentication and API Integration for SafeZone Web App

This document explains how the SafeZone web application handles authentication credentials for API requests.

## Overview

The web application is configured to include authentication credentials in all API requests to the Django backend. This is required because the backend uses Auth0 JWT authentication and has CORS configured with `CORS_ALLOW_CREDENTIALS = True`.

## Key Components

### 1. API Configuration (`src/lib/api-config.ts`)

Central configuration for API endpoints and Auth0 settings. Reads from environment variables:

- `VITE_API_BASE_URL`: Backend API base URL
- `VITE_AUTH0_DOMAIN`: Auth0 domain
- `VITE_AUTH0_CLIENT_ID`: Auth0 client ID
- `VITE_AUTH0_AUDIENCE`: Auth0 API audience

### 2. Authenticated Fetch Utility (`src/lib/api-client.ts`)

Custom fetch wrapper that automatically:
- Includes `credentials: 'include'` in all requests (required for CORS with credentials)
- Adds `Authorization: Bearer <token>` header when access token is provided
- Sets appropriate `Content-Type` headers
- Handles both relative and absolute URLs

### 3. Usage Examples

#### Basic GET Request

```typescript
import { apiGet } from '@/lib/api-client';

// Without authentication
const response = await apiGet('/api/public-endpoint');

// With authentication token
const response = await apiGet('/api/protected-endpoint', accessToken);
```

#### POST Request with Data

```typescript
import { apiPost } from '@/lib/api-client';

const data = { title: 'New Report', description: 'Details...' };
const response = await apiPost('/api/incidents/', data, accessToken);
```

#### Using with React Query

```typescript
import { useQuery } from '@tanstack/react-query';
import { apiGet } from '@/lib/api-client';

function useIncidents(accessToken?: string) {
  return useQuery({
    queryKey: ['incidents'],
    queryFn: async () => {
      const response = await apiGet('/api/incidents/', accessToken);
      if (!response.ok) throw new Error('Failed to fetch incidents');
      return response.json();
    },
  });
}
```

## Environment Setup

1. Copy `.env.example` to `.env.local`:
   ```bash
   cp .env.example .env.local
   ```

2. Update the values in `.env.local`:
   ```env
   VITE_API_BASE_URL=http://localhost:8000
   VITE_AUTH0_DOMAIN=your-domain.auth0.com
   VITE_AUTH0_CLIENT_ID=your-client-id
   VITE_AUTH0_AUDIENCE=your-api-audience
   ```

## CORS Configuration

The backend is configured to accept credentials. Ensure your backend has:

```python
# Django settings.py
CORS_ALLOW_CREDENTIALS = True
CORS_ALLOWED_ORIGINS = ['http://localhost:8080']  # or your frontend URL
```

## Authentication Flow

1. **User Authentication**: Implement Auth0 login flow in your React components
2. **Token Storage**: Store access token securely (e.g., in memory or secure storage)
3. **API Requests**: Pass access token to API helper functions
4. **Automatic Headers**: `authenticatedFetch` adds Bearer token and credentials automatically

## Why `credentials: 'include'` is Important

The `credentials: 'include'` option in fetch ensures that:
- Cookies are included in cross-origin requests
- Authentication credentials are sent to the backend
- CORS preflight requests are handled correctly

This is required when the backend has `CORS_ALLOW_CREDENTIALS = True`.

## Security Best Practices

1. **Never commit `.env.local`** - It's ignored by git by default
2. **Use HTTPS in production** - Credentials should only be sent over secure connections
3. **Implement token refresh** - Handle expired tokens gracefully
4. **Validate tokens server-side** - Never trust client-side validation alone

## Troubleshooting

### CORS Errors

If you see CORS errors:
1. Verify backend has correct `CORS_ALLOWED_ORIGINS` configured
2. Check that `CORS_ALLOW_CREDENTIALS = True` on backend
3. Ensure you're using `credentials: 'include'` in fetch

### Authentication Errors (401)

If you get 401 errors:
1. Verify access token is valid and not expired
2. Check that token is being passed to API functions
3. Verify Auth0 configuration matches backend

### Missing Authorization Header

The `authenticatedFetch` function only adds Authorization header when `accessToken` is provided. Make sure to pass the token parameter.

## Integration with Auth0

To fully integrate Auth0 authentication:

1. Install Auth0 SDK:
   ```bash
   npm install @auth0/auth0-react
   ```

2. Wrap your app with Auth0Provider (in `main.tsx` or `App.tsx`)

3. Use the `useAuth0` hook to get access tokens

4. Pass tokens to API helper functions

See the Flutter app implementation at `frontend/lib/authentication/` for reference.

## Related Files

- Backend authentication: `backend/safezone_backend/authentication/auth0.py`
- Backend settings: `backend/safezone_backend/safezone_backend/settings.py`
- Flutter auth client: `frontend/lib/authentication/services/api_client.dart`
