from django.contrib import admin
from .models import Incident


@admin.register(Incident)
class IncidentAdmin(admin.ModelAdmin):
    """Admin configuration for Incident model."""
    
    list_display = [
        'id',
        'category',
        'title',
        'latitude',
        'longitude',
        'timestamp',
        'confirmed_by',
        'notify_nearby',
    ]
    list_filter = ['category', 'timestamp', 'notify_nearby']
    search_fields = ['title', 'description', 'category']
    readonly_fields = ['timestamp']
    ordering = ['-timestamp']

