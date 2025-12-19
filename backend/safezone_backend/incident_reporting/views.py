from rest_framework import generics, status
from rest_framework.response import Response
from .models import Incident
from .serializers import IncidentSerializer, IncidentCreateSerializer


class IncidentListCreateView(generics.ListCreateAPIView):
    """
    List all incidents or create a new incident.
    
    GET: Returns list of all incidents ordered by timestamp (newest first)
    POST: Creates a new incident report
    """
    queryset = Incident.objects.all().order_by('-timestamp')
    
    def get_serializer_class(self):
        if self.request.method == 'POST':
            return IncidentCreateSerializer
        return IncidentSerializer


class IncidentRetrieveView(generics.RetrieveAPIView):
    """
    Retrieve a specific incident by ID.
    
    GET: Returns details of a single incident
    """
    queryset = Incident.objects.all()
    serializer_class = IncidentSerializer
    lookup_field = 'id'

