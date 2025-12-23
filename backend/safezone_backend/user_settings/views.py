from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from django.conf import settings
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from .models import UserDevice, SafeZone, UserPreferences, hash_device_id
from django.contrib.auth.models import User
from .serializers import UserDeviceSerializer, SafeZoneSerializer, UserPreferencesSerializer


def get_or_create_user_from_auth(request):
    """
    Get or create a Django User from the authenticated Auth0 user.
    
    This helper function extracts user information from Auth0 JWT tokens
    and creates/updates a corresponding Django User record.
    
    Args:
        request: The request object containing the authenticated user
        
    Returns:
        User instance or None if user creation/retrieval fails
    """
    # Get the Auth0 user from the request
    auth_user = request.user
    
    # Check if this is an Auth0User (from JWT authentication)
    if hasattr(auth_user, 'sub'):
        # Use Auth0 sub (subject) as the username
        username = auth_user.sub
        email = getattr(auth_user, 'email', None)
        
        # Get or create Django User
        user, created = User.objects.get_or_create(
            username=username,
            defaults={
                'email': email or '',
                'is_active': True,
            }
        )
        
        # Update email if it changed
        if email and user.email != email:
            user.email = email
            user.save()
        
        return user
    elif isinstance(auth_user, User):
        # Already a Django User (e.g., from session authentication in tests)
        return auth_user
    
    return None


@method_decorator(csrf_exempt, name='dispatch')
class UserDeviceRegisterView(generics.CreateAPIView):
    """
    Register or update a user device for push notifications.
    
    POST: Register device with FCM token (requires authentication)
    """
    queryset = UserDevice.objects.all()
    serializer_class = UserDeviceSerializer
    permission_classes = [IsAuthenticated]
    
    def create(self, request, *args, **kwargs):
        """Create or update device registration."""
        device_id = request.data.get('device_id')
        
        if not device_id:
            return Response(
                {'error': 'device_id is required'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        # Get or create the Django User from Auth0 info
        user = get_or_create_user_from_auth(request)
        
        # Check if device already exists
        # NOTE: Due to encrypted fields not supporting efficient database-level filtering,
        # we iterate through devices. For production with large datasets, consider:
        # 1. Adding a hash field for device_id to enable indexed lookups
        # 2. Implementing a caching layer for device lookups
        # 3. Using a separate non-encrypted lookup field
        device = None
        for d in UserDevice.objects.all():
            if d.device_id == device_id:
                device = d
                break
        
        if device:
            # Update existing device
            serializer = self.get_serializer(device, data=request.data)
            serializer.is_valid(raise_exception=True)
            serializer.save(user=user)
            return Response(serializer.data)
        else:
            # Create new device
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            serializer.save(user=user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)


@method_decorator(csrf_exempt, name='dispatch')
class SafeZoneListCreateView(generics.ListCreateAPIView):
    """
    List all safe zones for a device or create a new safe zone.
    
    GET: Returns list of safe zones for the device
    POST: Creates a new safe zone
    """
    serializer_class = SafeZoneSerializer
    
    def get_permissions(self):
        """
        Use AllowAny in development without Auth0, otherwise require auth.
        """
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [IsAuthenticated()]
    
    def get_queryset(self):
        """Filter safe zones by device_id from query params."""
        device_id = self.request.query_params.get('device_id')
        if device_id:
            # Use hash-based lookup for efficient filtering
            device_id_hash = hash_device_id(device_id)
            return SafeZone.objects.filter(device_id_hash=device_id_hash)
        return SafeZone.objects.all()
    
    def list(self, request, *args, **kwargs):
        """Override list to ensure paginated response format."""
        queryset = self.get_queryset()
        
        # Handle list from get_queryset which may return a list due to encrypted field filtering
        if isinstance(queryset, list):
            serializer = self.get_serializer(queryset, many=True)
            return Response({
                'count': len(serializer.data),
                'next': None,
                'previous': None,
                'results': serializer.data
            })
        
        # Standard queryset pagination
        queryset = self.filter_queryset(queryset)
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = self.get_serializer(queryset, many=True)
        return Response({
            'count': len(serializer.data),
            'next': None,
            'previous': None,
            'results': serializer.data
        })
    
    def perform_create(self, serializer):
        """Associate the safe zone with the authenticated user when creating."""
        # Get or create the Django User from Auth0 info
        user = get_or_create_user_from_auth(self.request)
        serializer.save(user=user)


@method_decorator(csrf_exempt, name='dispatch')
class SafeZoneDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Retrieve, update, or delete a specific safe zone.
    
    GET: Returns safe zone details
    PUT/PATCH: Updates safe zone
    DELETE: Deletes safe zone
    """
    queryset = SafeZone.objects.all()
    serializer_class = SafeZoneSerializer
    lookup_field = 'id'
    
    def get_permissions(self):
        """
        Use AllowAny in development without Auth0, otherwise require auth.
        """
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [IsAuthenticated()]


@method_decorator(csrf_exempt, name='dispatch')
class UserPreferencesView(generics.RetrieveUpdateAPIView):
    """
    Retrieve or update user preferences for a device.
    
    GET: Returns user preferences for the device (requires authentication)
    PUT/PATCH: Updates user preferences (requires authentication)
    """
    serializer_class = UserPreferencesSerializer
    lookup_field = 'device_id'
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        """Return preferences for all devices."""
        return UserPreferences.objects.all()
    
    def get_object(self):
        """Get or create preferences for the device_id."""
        device_id = self.kwargs.get('device_id')
        if not device_id:
            device_id = self.request.query_params.get('device_id')
        
        if not device_id:
            return Response(
                {'error': 'device_id is required'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        # Get or create preferences for this device
        preferences, created = UserPreferences.objects.get_or_create(
            device_id=device_id
        )
        return preferences



