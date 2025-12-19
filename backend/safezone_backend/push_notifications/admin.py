from django.contrib import admin
from .models import NotificationLog


@admin.register(NotificationLog)
class NotificationLogAdmin(admin.ModelAdmin):
    """Admin configuration for NotificationLog model."""
    
    list_display = [
        'incident',
        'device_id',
        'sent_at',
        'success',
    ]
    list_filter = ['success', 'sent_at']
    search_fields = ['device_id', 'incident__title']
    readonly_fields = ['sent_at']

