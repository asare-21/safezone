from rest_framework import serializers
from .models import UserDevice, SafeZone


class UserDeviceSerializer(serializers.ModelSerializer):
    """Serializer for UserDevice model."""
    
    class Meta:
        model = UserDevice
        fields = [
            'id',
            'device_id',
            'fcm_token',
            'platform',
            'is_active',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class SafeZoneSerializer(serializers.ModelSerializer):
    """Serializer for SafeZone model."""
    
    class Meta:
        model = SafeZone
        fields = [
            'id',
            'device_id',
            'name',
            'latitude',
            'longitude',
            'radius',
            'zone_type',
            'is_active',
            'notify_on_enter',
            'notify_on_exit',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
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
    
    def validate_radius(self, value):
        """Validate radius is positive and reasonable."""
        if value <= 0:
            raise serializers.ValidationError('Radius must be greater than 0')
        if value > 50000:  # 50km max
            raise serializers.ValidationError(
                'Radius must be less than 50000 meters (50km)'
            )
        return value
