from django.urls import path
from .views import (
    UserProfileView,
    LeaderboardView,
    ConfirmIncidentView,
    UserBadgesView,
)

urlpatterns = [
    # User profile endpoints
    path('profile/<str:device_id>/', UserProfileView.as_view(), name='user-profile'),
    path('profile/<str:device_id>/badges/', UserBadgesView.as_view(), name='user-badges'),
    
    # Leaderboard
    path('leaderboard/', LeaderboardView.as_view(), name='leaderboard'),
    
    # Confirmation endpoint
    path('incidents/<int:incident_id>/confirm/', ConfirmIncidentView.as_view(), name='confirm-incident'),
]
