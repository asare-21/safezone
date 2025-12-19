from django.urls import path
from .views import (
    EmergencyContactListCreateView,
    EmergencyContactDetailView,
)

urlpatterns = [
    path('emergency-contacts/', EmergencyContactListCreateView.as_view(), name='emergency-contact-list-create'),
    path('emergency-contacts/<int:id>/', EmergencyContactDetailView.as_view(), name='emergency-contact-detail'),
]
