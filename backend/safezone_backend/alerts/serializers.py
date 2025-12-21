from rest_framework import serializers
from .models import Alert
from incident_reporting.serializers import IncidentSerializer


class AlertSerializer(serializers.ModelSerializer):
    """Serializer for Alert model with nested incident data."""
    
    incident = IncidentSerializer(read_only=True)
    time_ago = serializers.SerializerMethodField()
    
    class Meta:
        model = Alert
        fields = [
            'id',
            'incident',
            'alert_type',
            'severity',
            'title',
            'location',
            'timestamp',
            'confirmed_by',
            'distance_meters',
            'time_ago',
        ]
        read_only_fields = ['id', 'timestamp', 'time_ago']
    
    def get_time_ago(self, obj):
        """Calculate human-readable time difference."""
        from django.utils import timezone
        now = timezone.now()
        diff = now - obj.timestamp
        
        minutes = int(diff.total_seconds() / 60)
        hours = int(minutes / 60)
        days = int(hours / 24)
        
        if minutes < 60:
            return f"{minutes} mins ago"
        elif hours < 24:
            return f"{hours} hour{'s' if hours > 1 else ''} ago"
        else:
            return f"{days} day{'s' if days > 1 else ''} ago"


class AlertListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for listing alerts without full incident data."""
    
    incident_id = serializers.IntegerField(source='incident.id', read_only=True)
    incident_category = serializers.CharField(
        source='incident.category',
        read_only=True
    )
    incident_latitude = serializers.FloatField(
        source='incident.latitude',
        read_only=True
    )
    incident_longitude = serializers.FloatField(
        source='incident.longitude',
        read_only=True
    )
    time_ago = serializers.SerializerMethodField()
    
    class Meta:
        model = Alert
        fields = [
            'id',
            'incident_id',
            'incident_category',
            'incident_latitude',
            'incident_longitude',
            'alert_type',
            'severity',
            'title',
            'location',
            'timestamp',
            'confirmed_by',
            'distance_meters',
            'time_ago',
        ]
        read_only_fields = ['id', 'timestamp', 'time_ago']
    
    def get_time_ago(self, obj):
        """Calculate human-readable time difference."""
        from django.utils import timezone
        now = timezone.now()
        diff = now - obj.timestamp
        
        minutes = int(diff.total_seconds() / 60)
        hours = int(minutes / 60)
        days = int(hours / 24)
        
        if minutes < 60:
            return f"{minutes} mins ago"
        elif hours < 24:
            return f"{hours} hour{'s' if hours > 1 else ''} ago"
        else:
            return f"{days} day{'s' if days > 1 else ''} ago"
