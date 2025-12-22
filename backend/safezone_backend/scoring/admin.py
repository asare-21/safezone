from django.contrib import admin
from .models import UserProfile, Badge, IncidentConfirmation


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    """Admin interface for UserProfile model."""
    
    list_display = [
        'id',
        'device_id_preview',
        'total_points',
        'current_tier',
        'tier_name',
        'reports_count',
        'confirmations_count',
        'accuracy_percentage',
        'created_at',
    ]
    list_filter = ['current_tier', 'created_at']
    search_fields = ['device_id']
    readonly_fields = [
        'tier_name',
        'tier_icon',
        'accuracy_percentage',
        'created_at',
        'updated_at',
    ]
    ordering = ['-total_points']
    
    def device_id_preview(self, obj):
        """Show first 8 chars of device_id."""
        return f"{str(obj.device_id)[:8]}..."
    device_id_preview.short_description = 'Device ID'


@admin.register(Badge)
class BadgeAdmin(admin.ModelAdmin):
    """Admin interface for Badge model."""
    
    list_display = [
        'id',
        'profile',
        'badge_type',
        'badge_icon',
        'earned_at',
    ]
    list_filter = ['badge_type', 'earned_at']
    search_fields = ['profile__device_id']
    readonly_fields = ['earned_at']
    ordering = ['-earned_at']


@admin.register(IncidentConfirmation)
class IncidentConfirmationAdmin(admin.ModelAdmin):
    """Admin interface for IncidentConfirmation model."""
    
    list_display = [
        'id',
        'incident',
        'device_id_preview',
        'confirmed_at',
    ]
    list_filter = ['confirmed_at']
    search_fields = ['incident__id', 'device_id']
    readonly_fields = ['confirmed_at']
    ordering = ['-confirmed_at']
    
    def device_id_preview(self, obj):
        """Show first 8 chars of device_id."""
        return f"{str(obj.device_id)[:8]}..."
    device_id_preview.short_description = 'Device ID'
