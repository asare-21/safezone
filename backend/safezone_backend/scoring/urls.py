from django.urls import path
from .views import (
    UserProfileView,
    LeaderboardView,
    ConfirmIncidentView,
    UserBadgesView,
    NearbyIncidentsView,
    UserIncidentsView,
)

urlpatterns = [
    # User profile endpoints
    path('profile/<str:device_id>/', UserProfileView.as_view(), name='user-profile'),
    path('profile/<str:device_id>/badges/', UserBadgesView.as_view(), name='user-badges'),
    path('profile/<str:device_id>/incidents/', UserIncidentsView.as_view(), name='user-incidents'),
    
    # Leaderboard
    path('leaderboard/', LeaderboardView.as_view(), name='leaderboard'),
    
    # Confirmation endpoint
    path('incidents/<int:incident_id>/confirm/', ConfirmIncidentView.as_view(), name='confirm-incident'),
    
    # Nearby incidents check
    path('incidents/nearby/', NearbyIncidentsView.as_view(), name='nearby-incidents'),
]
