from django.contrib import admin
from .models import Guide


@admin.register(Guide)
class GuideAdmin(admin.ModelAdmin):
    """Admin interface for Guide model."""
    
    list_display = ['title', 'section', 'order', 'is_active', 'updated_at']
    list_filter = ['section', 'is_active']
    search_fields = ['title', 'content']
    ordering = ['section', 'order']
    list_editable = ['order', 'is_active']
