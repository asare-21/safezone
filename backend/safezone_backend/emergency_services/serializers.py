from rest_framework import serializers
from .models import EmergencyService


class EmergencyServiceSerializer(serializers.ModelSerializer):
    """Serializer for EmergencyService model."""
    
    class Meta:
        model = EmergencyService
        fields = [
            'id',
            'country_code',
            'name',
            'service_type',
            'phone_number',
            'latitude',
            'longitude',
            'address',
            'hours',
            'is_active',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def validate_country_code(self, value):
        """Validate country code is 2 characters uppercase."""
        if len(value) != 2:
            raise serializers.ValidationError(
                'Country code must be exactly 2 characters (ISO 3166-1 alpha-2)'
            )
        return value.upper()
    
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
