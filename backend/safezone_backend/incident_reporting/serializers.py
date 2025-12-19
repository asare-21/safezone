from rest_framework import serializers
from .models import Incident


class IncidentSerializer(serializers.ModelSerializer):
    """Serializer for Incident model."""

    class Meta:
        model = Incident
        fields = [
            'id',
            'category',
            'latitude',
            'longitude',
            'title',
            'description',
            'timestamp',
            'confirmed_by',
            'notify_nearby',
        ]
        read_only_fields = ['id', 'timestamp']


class IncidentCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating incidents."""

    class Meta:
        model = Incident
        fields = [
            'category',
            'latitude',
            'longitude',
            'title',
            'description',
            'notify_nearby',
        ]

    def validate_latitude(self, value):
        """Validate latitude is within valid range."""
        if value < -90 or value > 90:
            raise serializers.ValidationError(
                'Latitude must be between -90 and 90'
            )
        return value

    def validate_longitude(self, value):
        """Validate longitude is within valid range."""
        if value < -180 or value > 180:
            raise serializers.ValidationError(
                'Longitude must be between -180 and 180'
            )
        return value
