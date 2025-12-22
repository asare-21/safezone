from rest_framework import generics, status, views
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from django.conf import settings
from django.shortcuts import get_object_or_404
from django.db import IntegrityError
from .models import UserProfile, Badge, IncidentConfirmation, hash_device_id
from .serializers import (
    UserProfileSerializer,
    UserProfileSummarySerializer,
    BadgeSerializer,
    ConfirmIncidentRequestSerializer,
    ScoringResponseSerializer,
)
from incident_reporting.models import Incident
import logging

logger = logging.getLogger(__name__)


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
