from rest_framework import generics, status, views
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django.conf import settings
from django.shortcuts import get_object_or_404
from django.db import IntegrityError
from django.utils import timezone
from datetime import timedelta
from .models import UserProfile, Badge, IncidentConfirmation, hash_device_id
from .serializers import (
    UserProfileSerializer,
    UserProfileSummarySerializer,
    BadgeSerializer,
    ConfirmIncidentRequestSerializer,
    ScoringResponseSerializer,
)
from incident_reporting.models import Incident
from alerts.utils import haversine_distance
import logging

logger = logging.getLogger(__name__)

# Scoring constants
INCIDENT_REPORT_BASE_POINTS = 10
INCIDENT_CONFIRMATION_BONUS_MULTIPLIER = 2
MAX_CONFIRMATION_BONUS_COUNT = 10
VERIFIED_STATUS_THRESHOLD = 5


class UserProfileView(generics.RetrieveAPIView):
    """
    Retrieve user profile by device_id.
    
    GET: Returns user profile with scoring data, badges, and tier information.
    """
    serializer_class = UserProfileSerializer
    lookup_field = 'device_id'
    
    def get_permissions(self):
        """Allow unauthenticated access in development."""
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [AllowAny()]  # For now, allow anyone to check profiles
    
    def get_queryset(self):
        return UserProfile.objects.all()
    
    def get_object(self):
        """Get or create user profile."""
        device_id = self.kwargs.get('device_id')
        device_id_hash = hash_device_id(device_id)
        profile, created = UserProfile.objects.get_or_create(
            device_id_hash=device_id_hash,
            defaults={'device_id': device_id}
        )
        if created:
            logger.info(f"Created new user profile for device hash {device_id_hash[:8]}...")
        return profile


class LeaderboardView(generics.ListAPIView):
    """
    Retrieve leaderboard of top users.
    
    GET: Returns list of top users ordered by total_points.
    """
    serializer_class = UserProfileSummarySerializer
    queryset = UserProfile.objects.all().order_by('-total_points')[:100]
    
    def get_permissions(self):
        """Allow unauthenticated access in development."""
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [AllowAny()]  # For now, allow anyone to view leaderboard


class ConfirmIncidentView(views.APIView):
    """
    Confirm an incident and award points.
    
    POST: Confirms an incident by device_id and awards confirmation points.
    """
    
    def get_permissions(self):
        """Allow unauthenticated access in development."""
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [AllowAny()]
    
    def post(self, request, incident_id):
        """Confirm an incident."""
        serializer = ConfirmIncidentRequestSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        device_id = serializer.validated_data['device_id']
        device_id_hash = hash_device_id(device_id)
        
        # Get the incident
        incident = get_object_or_404(Incident, id=incident_id)
        
        # Get or create user profile
        profile, _ = UserProfile.objects.get_or_create(
            device_id_hash=device_id_hash,
            defaults={'device_id': device_id}
        )
        
        # Check if already confirmed and create confirmation
        try:
            confirmation = IncidentConfirmation.objects.create(
                incident=incident,
                device_id=device_id
            )
        except IntegrityError:
            return Response(
                {'error': 'You have already confirmed this incident'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Update incident confirmed_by count
        confirmation_count = IncidentConfirmation.objects.filter(incident=incident).count()
        incident.confirmed_by = confirmation_count
        incident.save()
        
        # Award points (max 10 confirmations)
        if confirmation_count <= 10:
            scoring_result = profile.add_confirmation_points()
            
            # Check for Truth Triangulator badge (5+ confirmations)
            if profile.confirmations_count >= 5:
                Badge.objects.get_or_create(
                    profile=profile,
                    badge_type='truth_triangulator'
                )
            
            # Prepare response
            response_data = {
                'points_earned': scoring_result['points_earned'],
                'total_points': scoring_result['total_points'],
                'tier_changed': scoring_result['tier_changed'],
                'new_tier': scoring_result.get('new_tier'),
                'tier_name': profile.tier_name if scoring_result['tier_changed'] else None,
                'tier_icon': profile.tier_icon if scoring_result['tier_changed'] else None,
                'message': 'Incident confirmed successfully!',
                'confirmation_count': confirmation_count,
            }
            
            return Response(response_data, status=status.HTTP_200_OK)
        else:
            return Response(
                {
                    'message': 'Incident confirmed but max confirmations reached',
                    'confirmation_count': confirmation_count,
                },
                status=status.HTTP_200_OK
            )


class UserBadgesView(generics.ListAPIView):
    """
    Retrieve user badges.
    
    GET: Returns list of badges earned by the user.
    """
    serializer_class = BadgeSerializer
    
    def get_permissions(self):
        """Allow unauthenticated access in development."""
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [AllowAny()]
    
    def get_queryset(self):
        device_id = self.kwargs.get('device_id')
        device_id_hash = hash_device_id(device_id)
        try:
            profile = UserProfile.objects.get(device_id_hash=device_id_hash)
            return Badge.objects.filter(profile=profile)
        except UserProfile.DoesNotExist:
            return Badge.objects.none()


class UserIncidentsView(views.APIView):
    """
    Get incidents reported by a specific user.
    
    GET: Returns list of incidents reported by the user (identified by device_id).
    """
    
    def get_permissions(self):
        """Allow unauthenticated access in development."""
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [AllowAny()]
    
    def get(self, request, device_id):
        """Get incidents reported by the user."""
        device_id_hash = hash_device_id(device_id)
        
        # Get incidents reported by this user
        incidents = Incident.objects.filter(
            reporter_device_id_hash=device_id_hash
        ).order_by('-timestamp')
        
        # Get confirmation counts for each incident
        incident_data = []
        for incident in incidents:
            confirmation_count = IncidentConfirmation.objects.filter(
                incident=incident
            ).count()
            
            # Calculate impact score using constants
            confirmation_bonus = min(
                confirmation_count, MAX_CONFIRMATION_BONUS_COUNT
            ) * INCIDENT_CONFIRMATION_BONUS_MULTIPLIER
            impact_score = INCIDENT_REPORT_BASE_POINTS + confirmation_bonus
            
            # Determine incident status based on confirmation count
            if confirmation_count >= VERIFIED_STATUS_THRESHOLD:
                incident_status = 'verified'
            else:
                incident_status = 'pending'
            
            incident_data.append({
                'id': incident.id,
                'category': incident.category,
                'title': incident.title,
                'description': incident.description,
                'latitude': incident.latitude,
                'longitude': incident.longitude,
                'timestamp': incident.timestamp.isoformat(),
                'confirmed_by': confirmation_count,
                'status': incident_status,
                'impact_score': impact_score,
            })
        
        return Response({
            'count': len(incident_data),
            'incidents': incident_data,
        }, status=status.HTTP_200_OK)


class NearbyIncidentsView(views.APIView):
    """
    Check for nearby unconfirmed incidents.
    
    POST: Returns incidents within radius that user hasn't confirmed yet.
    """
    
    def get_permissions(self):
        """Allow unauthenticated access in development."""
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [AllowAny()]
    
    def post(self, request):
        """Get nearby unconfirmed incidents for the user."""
        latitude = request.data.get('latitude')
        longitude = request.data.get('longitude')
        device_id = request.data.get('device_id')
        
        if not latitude or not longitude or not device_id:
            return Response(
                {'error': 'latitude, longitude, and device_id are required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Parse and validate radius_km
            try:
                radius_km = float(request.data.get('radius_km', 0.5))
            except (ValueError, TypeError):
                radius_km = 0.5  # Default to 0.5km (500 meters) if invalid
            
            # Parse and validate hours
            try:
                hours = int(request.data.get('hours', 24))
            except (ValueError, TypeError):
                hours = 24  # Default to 24 hours if invalid
            
            lat = float(latitude)
            lon = float(longitude)
            radius = min(radius_km, 10)  # Max 10km
            
            # Get device_id hash
            device_id_hash = hash_device_id(device_id)
            
            # Get recent incidents
            time_threshold = timezone.now() - timedelta(hours=hours)
            recent_incidents = Incident.objects.filter(
                timestamp__gte=time_threshold
            )
            
            # Get user's confirmations to filter out already confirmed incidents
            user_confirmations = IncidentConfirmation.objects.filter(
                device_id_hash=device_id_hash
            ).values_list('incident_id', flat=True)
            
            # Find nearby unconfirmed incidents
            nearby_unconfirmed = []
            for incident in recent_incidents:
                # Skip if already confirmed by user
                if incident.id in user_confirmations:
                    continue
                
                # Skip if the user is the creator of the incident
                if incident.reporter_device_id_hash == device_id_hash:
                    continue
                
                # Calculate distance
                distance = haversine_distance(
                    lon, lat,
                    incident.longitude,
                    incident.latitude
                )
                
                if distance <= radius:
                    nearby_unconfirmed.append({
                        'id': incident.id,
                        'category': incident.category,
                        'title': incident.title,
                        'description': incident.description,
                        'latitude': incident.latitude,
                        'longitude': incident.longitude,
                        'timestamp': incident.timestamp,
                        'confirmed_by': incident.confirmed_by,
                        'distance_meters': round(distance * 1000, 2),
                    })
            
            # Sort by distance
            nearby_unconfirmed.sort(key=lambda x: x['distance_meters'])
            
            return Response({
                'count': len(nearby_unconfirmed),
                'incidents': nearby_unconfirmed,
            }, status=status.HTTP_200_OK)
            
        except (ValueError, TypeError) as e:
            return Response(
                {'error': f'Invalid parameters: {str(e)}'},
                status=status.HTTP_400_BAD_REQUEST
            )
