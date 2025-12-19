from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from .models import Incident
from .serializers import IncidentSerializer, IncidentCreateSerializer
import logging

logger = logging.getLogger(__name__)


class IncidentListCreateView(generics.ListCreateAPIView):
    """
    List all incidents or create a new incident.
    
    GET: Returns list of all incidents ordered by timestamp (newest first)
    POST: Creates a new incident report (requires authentication)
    """
    queryset = Incident.objects.all().order_by('-timestamp')
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return IncidentCreateSerializer
        return IncidentSerializer
    
    def perform_create(self, serializer):
        """Save the incident and trigger push notifications."""
        # Attach the authenticated user's ID if available
        extra_data = {}
        if hasattr(self.request.user, 'id'):
            extra_data['user_id'] = self.request.user.id
        
        incident = serializer.save(**extra_data)
        
        # Trigger push notifications to users with matching safe zones
        try:
            from push_notifications.utils import send_incident_notifications
            send_incident_notifications(incident)
        except Exception as e:
            # Don't fail the request if notifications fail
            logger.error(f"Failed to send notifications for incident {incident.id}: {e}")


class IncidentRetrieveView(generics.RetrieveAPIView):
    """
    Retrieve a specific incident by ID.
    
    GET: Returns details of a single incident
    """
    queryset = Incident.objects.all()
    serializer_class = IncidentSerializer
    lookup_field = 'id'
    permission_classes = [IsAuthenticatedOrReadOnly]


