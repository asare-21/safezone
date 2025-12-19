from django.contrib import admin
from .models import EmergencyContact


@admin.register(EmergencyContact)
class EmergencyContactAdmin(admin.ModelAdmin):
    """Admin interface for EmergencyContact model."""
    
    list_display = ['name', 'phone_number', 'relationship', 'priority', 'is_active', 'created_at']
    list_filter = ['relationship', 'is_active', 'created_at']
    search_fields = ['name', 'phone_number']
    ordering = ['priority', '-created_at']
