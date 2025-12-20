from django.urls import path
from .views import AlertListView, AlertRetrieveView, AlertGenerateView

urlpatterns = [
    path('alerts/', AlertListView.as_view(), name='alert-list'),
    path('alerts/<int:id>/', AlertRetrieveView.as_view(), name='alert-detail'),
    path('alerts/generate/', AlertGenerateView.as_view(), name='alert-generate'),
]
