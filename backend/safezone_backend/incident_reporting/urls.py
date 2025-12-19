from django.urls import path
from .views import IncidentListCreateView, IncidentRetrieveView

urlpatterns = [
    path('incidents/', IncidentListCreateView.as_view(), name='incident-list-create'),
    path('incidents/<int:id>/', IncidentRetrieveView.as_view(), name='incident-detail'),
]
