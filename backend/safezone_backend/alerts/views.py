from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from django.utils import timezone
from datetime import timedelta
import logging

from .models import Alert
from .serializers import AlertSerializer, AlertListSerializer
from incident_reporting.models import Incident

logger = logging.getLogger(__name__)


class AlertListView(generics.ListAPIView):
    """
    List all alerts with optional filtering.
    
    Query Parameters:
    - severity: Filter by severity (high, medium, low, info)
    - alert_type: Filter by alert type (highRisk, theft, eventCrowd, trafficCleared)
    - hours: Filter alerts from last N hours (default: 24)
    - latitude: User's latitude for distance-based alerts
    - longitude: User's longitude for distance-based alerts
    - radius_km: Maximum distance in km (default: 10, max: 50)
    """
    permission_classes = [IsAuthenticatedOrReadOnly]
    serializer_class = AlertListSerializer
    
    def get_queryset(self):
        queryset = Alert.objects.select_related('incident').all()
        
        # Filter by severity
        severity = self.request.query_params.get('severity', None)
        if severity:
            queryset = queryset.filter(severity=severity)
        
        # Filter by alert type
        alert_type = self.request.query_params.get('alert_type', None)
        if alert_type:
            queryset = queryset.filter(alert_type=alert_type)
        
        # Filter by time range (default: last 24 hours)
        hours = self.request.query_params.get('hours', None)
        if hours:
            try:
                hours_int = int(hours)
                time_threshold = timezone.now() - timedelta(hours=hours_int)
                queryset = queryset.filter(timestamp__gte=time_threshold)
            except ValueError:
                pass
        else:
            # Default to last 24 hours
            time_threshold = timezone.now() - timedelta(hours=24)
            queryset = queryset.filter(timestamp__gte=time_threshold)
        
        # Filter by proximity (if latitude and longitude provided)
        latitude = self.request.query_params.get('latitude', None)
        longitude = self.request.query_params.get('longitude', None)
        radius_km = self.request.query_params.get('radius_km', '10')
        
        if latitude and longitude:
            try:
                lat = float(latitude)
                lon = float(longitude)
                radius = min(float(radius_km), 50)  # Max 50km
                
                # Filter incidents within radius
                # Note: This is a simple implementation. For production,
                # use PostGIS for proper geospatial queries
                from math import radians, cos, sin, asin, sqrt
                
                def haversine(lon1, lat1, lon2, lat2):
                    """Calculate distance between two points in km."""
                    lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
                    dlon = lon2 - lon1
                    dlat = lat2 - lat1
                    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
                    c = 2 * asin(sqrt(a))
                    km = 6371 * c
                    return km
                
                # Filter alerts by distance
                nearby_alerts = []
                for alert in queryset:
                    distance = haversine(
                        lon, lat,
                        alert.incident.longitude,
                        alert.incident.latitude
                    )
                    if distance <= radius:
                        alert.distance_meters = distance * 1000  # Convert to meters
                        nearby_alerts.append(alert)
                
                # Update queryset with filtered alerts
                alert_ids = [a.id for a in nearby_alerts]
                queryset = queryset.filter(id__in=alert_ids)
                
            except (ValueError, TypeError) as e:
                logger.warning(f"Invalid location parameters: {e}")
        
        return queryset.order_by('-timestamp')
    
    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        serializer = self.get_serializer(queryset, many=True)
        
        return Response({
            'count': len(serializer.data),
            'results': serializer.data
        })


class AlertRetrieveView(generics.RetrieveAPIView):
    """
    Retrieve a specific alert by ID with full incident details.
    """
    queryset = Alert.objects.select_related('incident').all()
    serializer_class = AlertSerializer
    permission_classes = [IsAuthenticatedOrReadOnly]
    lookup_field = 'id'


class AlertGenerateView(generics.GenericAPIView):
    """
    Generate alerts from recent incidents based on user location.
    
    POST Parameters:
    - latitude: User's latitude
    - longitude: User's longitude
    - radius_km: Maximum distance in km (default: 5, max: 50)
    - hours: Look at incidents from last N hours (default: 24)
    """
    permission_classes = [IsAuthenticatedOrReadOnly]
    
    def post(self, request):
        latitude = request.data.get('latitude')
        longitude = request.data.get('longitude')
        radius_km = float(request.data.get('radius_km', 5))
        hours = int(request.data.get('hours', 24))
        
        if not latitude or not longitude:
            return Response(
                {'error': 'latitude and longitude are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            lat = float(latitude)
            lon = float(longitude)
            radius = min(radius_km, 50)  # Max 50km
            
            # Get recent incidents
            time_threshold = timezone.now() - timedelta(hours=hours)
            recent_incidents = Incident.objects.filter(
                timestamp__gte=time_threshold
            )
            
            # Calculate distance and generate alerts for nearby incidents
            from math import radians, cos, sin, asin, sqrt
            
            def haversine(lon1, lat1, lon2, lat2):
                """Calculate distance between two points in km."""
                lon1, lat1, lon2, lat2 = map(radians, [lon1, lat1, lon2, lat2])
                dlon = lon2 - lon1
                dlat = lat2 - lat1
                a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
                c = 2 * asin(sqrt(a))
                km = 6371 * c
                return km
            
            generated_alerts = []
            for incident in recent_incidents:
                distance = haversine(
                    lon, lat,
                    incident.longitude,
                    incident.latitude
                )
                
                if distance <= radius:
                    # Check if alert already exists for this incident
                    existing_alert = Alert.objects.filter(
                        incident=incident
                    ).first()
                    
                    if not existing_alert:
                        alert = Alert.generate_alert_from_incident(
                            incident,
                            distance_meters=distance * 1000
                        )
                        generated_alerts.append(alert)
            
            serializer = AlertListSerializer(generated_alerts, many=True)
            return Response({
                'count': len(generated_alerts),
                'alerts': serializer.data,
                'message': f'Generated {len(generated_alerts)} alerts'
            }, status=status.HTTP_201_CREATED)
            
        except (ValueError, TypeError) as e:
            return Response(
                {'error': f'Invalid parameters: {str(e)}'},
                status=status.HTTP_400_BAD_REQUEST
            )
