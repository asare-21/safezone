from django.contrib import admin
from .models import EmergencyService


@admin.register(EmergencyService)
class EmergencyServiceAdmin(admin.ModelAdmin):
    """Admin interface for EmergencyService model."""
    
    list_display = ['name', 'country_code', 'service_type', 'phone_number', 'is_active']
    list_filter = ['country_code', 'service_type', 'is_active']
    search_fields = ['name', 'phone_number', 'address']
    ordering = ['country_code', 'service_type', 'name']
