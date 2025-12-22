from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly, AllowAny
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from django.conf import settings
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from .models import Incident
from .serializers import IncidentSerializer, IncidentCreateSerializer
import logging

logger = logging.getLogger(__name__)


@method_decorator(csrf_exempt, name='dispatch')
class IncidentListCreateView(generics.ListCreateAPIView):
    """
    List all incidents or create a new incident.
    
    GET: Returns list of all incidents ordered by timestamp (newest first)
    POST: Creates a new incident report (requires authentication in production)
    """
    queryset = Incident.objects.all().order_by('-timestamp')
    
    def get_permissions(self):
        """
        Use AllowAny in development without Auth0, otherwise require auth for writes.
        """
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [IsAuthenticatedOrReadOnly()]
    
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return IncidentCreateSerializer
        return IncidentSerializer
    
    def list(self, request, *args, **kwargs):
        """Override list to ensure paginated response format."""
        queryset = self.filter_queryset(self.get_queryset())
        
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
        """Save the incident and trigger push notifications and WebSocket broadcast."""
        # Save the incident (user tracking is handled by Auth0 authentication layer)
        incident = serializer.save()
        
        # Trigger push notifications to users with matching safe zones
        try:
            from push_notifications.utils import send_incident_notifications
            send_incident_notifications(incident)
        except Exception as e:
            # Don't fail the request if notifications fail
            logger.error(f"Failed to send notifications for incident {incident.id}: {e}")
        
        # Broadcast the new incident via WebSocket
        try:
            channel_layer = get_channel_layer()
            incident_data = IncidentSerializer(incident).data
            async_to_sync(channel_layer.group_send)(
                'incidents',
                {
                    'type': 'incident_update',
                    'incident': incident_data
                }
            )
        except Exception as e:
            # Don't fail the request if WebSocket broadcast fails
            logger.error(f"Failed to broadcast incident {incident.id} via WebSocket: {e}")


class IncidentRetrieveView(generics.RetrieveAPIView):
    """
    Retrieve a specific incident by ID.
    
    GET: Returns details of a single incident
    """
    queryset = Incident.objects.all()
    serializer_class = IncidentSerializer
    lookup_field = 'id'
    
    def get_permissions(self):
        """
        Use AllowAny in development without Auth0, otherwise require auth for writes.
        """
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [AllowAny()] # TODO: Change to IsAuthenticatedOrReadOnly() after testing


