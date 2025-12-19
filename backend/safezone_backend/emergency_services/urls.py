from django.urls import path
from .views import EmergencyServiceListView

urlpatterns = [
    path('emergency-services/', EmergencyServiceListView.as_view(), name='emergency-service-list'),
]
