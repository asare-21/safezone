from rest_framework import generics
from .models import Guide
from .serializers import GuideSerializer


class GuideListView(generics.ListAPIView):
    """
    List all active guides.
    
    GET: Returns list of all active guides ordered by section and order
    """
    serializer_class = GuideSerializer
    
    def get_queryset(self):
        """Return only active guides."""
        return Guide.objects.filter(is_active=True).order_by('section', 'order')


class GuideRetrieveView(generics.RetrieveAPIView):
    """
    Retrieve a specific guide by ID.
    
    GET: Returns details of a single guide
    """
    queryset = Guide.objects.all()
    serializer_class = GuideSerializer
    lookup_field = 'id'
