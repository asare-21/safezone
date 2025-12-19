from rest_framework import generics, status
from rest_framework.response import Response
from .models import UserDevice, SafeZone, UserPreferences
from .serializers import UserDeviceSerializer, SafeZoneSerializer, UserPreferencesSerializer


class UserDeviceRegisterView(generics.CreateAPIView):
    """
    Register or update a user device for push notifications.
    
    POST: Register device with FCM token
    """
    queryset = UserDevice.objects.all()
    serializer_class = UserDeviceSerializer
    
    def create(self, request, *args, **kwargs):
        """Create or update device registration."""
        device_id = request.data.get('device_id')
        
        if not device_id:
            return Response(
                {'error': 'device_id is required'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        # Check if device already exists
        device = UserDevice.objects.filter(device_id=device_id).first()
        
        if device:
            # Update existing device
            serializer = self.get_serializer(device, data=request.data)
            serializer.is_valid(raise_exception=True)
            serializer.save()
            return Response(serializer.data)
        else:
            # Create new device
            return super().create(request, *args, **kwargs)


class SafeZoneListCreateView(generics.ListCreateAPIView):
    """
    List all safe zones for a device or create a new safe zone.
    
    GET: Returns list of safe zones for the device
    POST: Creates a new safe zone
    """
    serializer_class = SafeZoneSerializer
    
    def get_queryset(self):
        """Filter safe zones by device_id from query params."""
        device_id = self.request.query_params.get('device_id')
        if device_id:
            return SafeZone.objects.filter(device_id=device_id)
        return SafeZone.objects.all()


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


class UserPreferencesView(generics.RetrieveUpdateAPIView):
    """
    Retrieve or update user preferences for a device.
    
    GET: Returns user preferences for the device
    PUT/PATCH: Updates user preferences
    """
    serializer_class = UserPreferencesSerializer
    lookup_field = 'device_id'
    
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


