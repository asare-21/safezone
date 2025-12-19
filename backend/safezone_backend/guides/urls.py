from django.urls import path
from .views import GuideListView, GuideRetrieveView

urlpatterns = [
    path('guides/', GuideListView.as_view(), name='guide-list'),
    path('guides/<int:id>/', GuideRetrieveView.as_view(), name='guide-detail'),
]
