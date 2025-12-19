from rest_framework import generics, status
from rest_framework.response import Response
from .models import EmergencyContact
from .serializers import EmergencyContactSerializer


class EmergencyContactListCreateView(generics.ListCreateAPIView):
    """
    List all emergency contacts for a device or create a new contact.
    
    GET: Returns list of emergency contacts for the device
    POST: Creates a new emergency contact
    """
    serializer_class = EmergencyContactSerializer
    
    def get_queryset(self):
        """
        Filter emergency contacts by device_id from query params.
        Note: Since device_id is encrypted, we filter in Python rather than at DB level.
        
        Performance consideration: This approach loads all active contacts into memory
        and filters them in Python. For production use with large datasets, consider:
        1. Adding a non-encrypted hash field for lookup
        2. Using a searchable encryption scheme
        3. Implementing pagination to limit memory usage
        """
        device_id = self.request.query_params.get('device_id')
        queryset = EmergencyContact.objects.filter(is_active=True)
        
        if device_id:
            # Filter by device_id in Python since it's an encrypted field
            filtered = [contact for contact in queryset if contact.device_id == device_id]
            # Return a queryset with the filtered IDs
            if filtered:
                ids = [contact.id for contact in filtered]
                return EmergencyContact.objects.filter(id__in=ids, is_active=True)
            return EmergencyContact.objects.none()
        
        return queryset


class EmergencyContactDetailView(generics.RetrieveUpdateDestroyAPIView):
    """
    Retrieve, update, or delete a specific emergency contact.
    
    GET: Returns emergency contact details
    PUT/PATCH: Updates emergency contact
    DELETE: Soft deletes emergency contact (sets is_active to False)
    """
    queryset = EmergencyContact.objects.all()
    serializer_class = EmergencyContactSerializer
    lookup_field = 'id'
    
    def destroy(self, request, *args, **kwargs):
        """Soft delete by setting is_active to False."""
        instance = self.get_object()
        instance.is_active = False
        instance.save()
        return Response(status=status.HTTP_204_NO_CONTENT)
