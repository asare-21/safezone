from rest_framework import serializers
from .models import Guide


class GuideSerializer(serializers.ModelSerializer):
    """Serializer for Guide model."""

    class Meta:
        model = Guide
        fields = [
            'id',
            'section',
            'title',
            'content',
            'icon',
            'order',
            'is_active',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
