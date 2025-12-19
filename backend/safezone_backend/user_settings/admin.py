from django.contrib import admin
from .models import UserDevice, SafeZone, UserPreferences


@admin.register(UserDevice)
class UserDeviceAdmin(admin.ModelAdmin):
    """Admin configuration for UserDevice model."""
    
    list_display = [
        'device_id',
        'platform',
        'is_active',
        'created_at',
        'updated_at',
    ]
    list_filter = ['platform', 'is_active', 'created_at']
    search_fields = ['device_id', 'fcm_token']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(SafeZone)
class SafeZoneAdmin(admin.ModelAdmin):
    """Admin configuration for SafeZone model."""
    
    list_display = [
        'name',
        'device_id',
        'zone_type',
        'is_active',
        'radius',
        'created_at',
    ]
    list_filter = ['zone_type', 'is_active', 'created_at']
    search_fields = ['name', 'device_id']
    readonly_fields = ['created_at', 'updated_at']


@admin.register(UserPreferences)
class UserPreferencesAdmin(admin.ModelAdmin):
    """Admin configuration for UserPreferences model."""
    
    list_display = [
        'device_id',
        'alert_radius',
        'default_zoom',
        'push_notifications',
        'proximity_alerts',
        'anonymous_reporting',
        'updated_at',
    ]
    list_filter = [
        'push_notifications',
        'proximity_alerts',
        'sound_vibration',
        'anonymous_reporting',
    ]
    search_fields = ['device_id']
    readonly_fields = ['created_at', 'updated_at']


