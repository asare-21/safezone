from rest_framework import generics
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticatedOrReadOnly, AllowAny
from django.conf import settings
from .models import Guide
from .serializers import GuideSerializer


class GuideListView(generics.ListAPIView):
    """
    List all active guides.
    
    GET: Returns list of all active guides ordered by section and order
    """
    serializer_class = GuideSerializer
    
    def get_permissions(self):
        """
        Use AllowAny in development without Auth0, otherwise require auth for writes.
        """
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [IsAuthenticatedOrReadOnly()]
    
    def get_queryset(self):
        """Return only active guides."""
        return Guide.objects.filter(is_active=True).order_by('section', 'order')
    
    def list(self, request, *args, **kwargs):
        """Override list to ensure paginated response format."""
        queryset = self.filter_queryset(self.get_queryset())
        
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = self.get_serializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = self.get_serializer(queryset, many=True)
        return Response({
            'count': len(serializer.data),
            'next': None,
            'previous': None,
            'results': serializer.data
        })


class GuideRetrieveView(generics.RetrieveAPIView):
    """
    Retrieve a specific guide by ID.
    
    GET: Returns details of a single guide
    """
    queryset = Guide.objects.all()
    serializer_class = GuideSerializer
    lookup_field = 'id'
    
    def get_permissions(self):
        """
        Use AllowAny in development without Auth0, otherwise require auth for writes.
        """
        if settings.DEBUG and not settings.AUTH0_DOMAIN:
            return [AllowAny()]
        return [IsAuthenticatedOrReadOnly()]
