from rest_framework import generics
from rest_framework.response import Response
from .models import EmergencyService
from .serializers import EmergencyServiceSerializer


class EmergencyServiceListView(generics.ListAPIView):
    """
    List emergency services filtered by country code and optionally by service type.
    
    Query parameters:
    - country_code (required): ISO 3166-1 alpha-2 country code (e.g., US, GH, NG)
    - service_type (optional): Filter by service type (police, hospital, fireStation, ambulance)
    
    GET: Returns list of emergency services for the specified country
    """
    serializer_class = EmergencyServiceSerializer
    
    def get_queryset(self):
        """Filter emergency services by country code and service type."""
        queryset = EmergencyService.objects.filter(is_active=True)
        
        country_code = self.request.query_params.get('country_code')
        if country_code:
            queryset = queryset.filter(country_code=country_code.upper())
        
        service_type = self.request.query_params.get('service_type')
        if service_type:
            queryset = queryset.filter(service_type=service_type)
        
        return queryset
    
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
            'results': serializer.data
        })
