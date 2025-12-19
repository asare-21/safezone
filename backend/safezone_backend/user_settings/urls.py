from django.urls import path
from .views import (
    UserDeviceRegisterView,
    SafeZoneListCreateView,
    SafeZoneDetailView,
    UserPreferencesView,
)

urlpatterns = [
    path('devices/register/', UserDeviceRegisterView.as_view(), name='device-register'),
    path('safe-zones/', SafeZoneListCreateView.as_view(), name='safe-zone-list-create'),
    path('safe-zones/<int:id>/', SafeZoneDetailView.as_view(), name='safe-zone-detail'),
    path('preferences/<str:device_id>/', UserPreferencesView.as_view(), name='user-preferences'),
]
