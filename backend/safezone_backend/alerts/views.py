from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly, AllowAny
from django.conf import settings
from django.utils import timezone
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from datetime import timedelta
import logging

from .models import Alert
from .serializers import AlertSerializer, AlertListSerializer
from .utils import haversine_distance
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
    serializer_class = AlertListSerializer
    
    def get_permissions(self):
        """
        Use AllowAny in development without Auth0, otherwise require auth for writes.
        """
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [IsAuthenticatedOrReadOnly()]
    
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
                
                # Filter incidents within radius using the utility function
                # Note: For production with large datasets, use PostGIS
                nearby_alerts = []
                for alert in queryset:
                    distance = haversine_distance(
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
    lookup_field = 'id'
    
    def get_permissions(self):
        """
        Use AllowAny in development without Auth0, otherwise require auth for writes.
        """
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [IsAuthenticatedOrReadOnly()]


@method_decorator(csrf_exempt, name='dispatch')
class AlertGenerateView(generics.GenericAPIView):
    """
    Generate alerts from recent incidents based on user location.
    
    POST Parameters:
    - latitude: User's latitude
    - longitude: User's longitude
    - radius_km: Maximum distance in km (default: 5, max: 50)
    - hours: Look at incidents from last N hours (default: 24)
    """
    
    def get_permissions(self):
        """
        Use AllowAny in development without Auth0, otherwise require auth for writes.
        """
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [IsAuthenticatedOrReadOnly()]
    
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
            generated_alerts = []
            for incident in recent_incidents:
                distance = haversine_distance(
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
