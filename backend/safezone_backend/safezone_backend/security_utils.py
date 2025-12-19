"""
Security utilities and data retention management for SafeZone.

This module provides utilities for:
- Data retention policy enforcement
- Secure data cleanup
- Privacy compliance helpers
"""

from datetime import timedelta
from django.utils import timezone
from django.conf import settings


def cleanup_expired_incidents():
    """
    Delete incident reports older than the retention period.
    Returns the number of incidents deleted.
    """
    from incident_reporting.models import Incident
    
    retention_days = getattr(settings, 'INCIDENT_RETENTION_DAYS', 90)
    cutoff_date = timezone.now() - timedelta(days=retention_days)
    
    expired_incidents = Incident.objects.filter(timestamp__lt=cutoff_date)
    count = expired_incidents.count()
    expired_incidents.delete()
    
    return count


def cleanup_inactive_user_preferences():
    """
    Delete user preferences that haven't been updated in the inactive period.
    Returns the number of preferences deleted.
    """
    from user_settings.models import UserPreferences
    
    inactive_days = getattr(settings, 'USER_PREFERENCES_INACTIVE_DAYS', 365)
    cutoff_date = timezone.now() - timedelta(days=inactive_days)
    
    inactive_prefs = UserPreferences.objects.filter(updated_at__lt=cutoff_date)
    count = inactive_prefs.count()
    inactive_prefs.delete()
    
    return count


def cleanup_inactive_device_tokens():
    """
    Delete device tokens that haven't been updated in the inactive period.
    Returns the number of device tokens deleted.
    """
    from user_settings.models import UserDevice
    
    inactive_days = getattr(settings, 'DEVICE_TOKEN_INACTIVE_DAYS', 180)
    cutoff_date = timezone.now() - timedelta(days=inactive_days)
    
    inactive_devices = UserDevice.objects.filter(
        updated_at__lt=cutoff_date,
        is_active=False
    )
    count = inactive_devices.count()
    inactive_devices.delete()
    
    return count


def anonymize_old_incidents():
    """
    Anonymize incident data older than retention period by removing
    identifying information while preserving aggregate statistics.
    Returns the number of incidents anonymized.
    """
    from incident_reporting.models import Incident
    
    retention_days = getattr(settings, 'INCIDENT_RETENTION_DAYS', 90)
    cutoff_date = timezone.now() - timedelta(days=retention_days)
    
    # For incidents older than retention period, we could:
    # - Round coordinates to reduce precision
    # - Remove detailed descriptions
    # - Keep only category and timestamp for trend analysis
    
    old_incidents = Incident.objects.filter(timestamp__lt=cutoff_date)
    count = old_incidents.count()
    
    # Example anonymization (customize based on needs)
    for incident in old_incidents:
        # Round coordinates to 2 decimal places (~1km precision)
        incident.latitude = round(incident.latitude, 2)
        incident.longitude = round(incident.longitude, 2)
        # Remove detailed description
        incident.description = "Historical incident - details removed for privacy"
        incident.title = f"{incident.get_category_display()} - Historical"
        incident.save()
    
    return count


def delete_user_data(device_id):
    """
    Delete all data associated with a device_id (for GDPR/CCPA compliance).
    This is used when a user requests data deletion.
    
    Args:
        device_id: The device identifier to delete data for
        
    Returns:
        dict: Summary of deleted items
    """
    from user_settings.models import UserDevice, UserPreferences, SafeZone
    from incident_reporting.models import Incident
    
    deleted = {
        'devices': 0,
        'preferences': 0,
        'safe_zones': 0,
        'incidents': 0,
    }
    
    # Delete user devices
    devices = UserDevice.objects.filter(device_id=device_id)
    deleted['devices'] = devices.count()
    devices.delete()
    
    # Delete user preferences
    prefs = UserPreferences.objects.filter(device_id=device_id)
    deleted['preferences'] = prefs.count()
    prefs.delete()
    
    # Delete safe zones
    zones = SafeZone.objects.filter(device_id=device_id)
    deleted['safe_zones'] = zones.count()
    zones.delete()
    
    # Note: Incidents are typically kept for community safety
    # but can be anonymized or deleted based on policy
    # For now, we'll keep incidents but could add deletion here if needed
    
    return deleted


def export_user_data(device_id):
    """
    Export all data associated with a device_id (for GDPR data portability).
    
    Args:
        device_id: The device identifier to export data for
        
    Returns:
        dict: All user data in a portable format
    """
    from user_settings.models import UserDevice, UserPreferences, SafeZone
    from incident_reporting.models import Incident
    
    data = {
        'device_id': device_id,
        'export_date': timezone.now().isoformat(),
        'devices': [],
        'preferences': {},
        'safe_zones': [],
        'incidents': [],
    }
    
    # Export devices
    devices = UserDevice.objects.filter(device_id=device_id)
    for device in devices:
        data['devices'].append({
            'platform': device.platform,
            'created_at': device.created_at.isoformat(),
            'updated_at': device.updated_at.isoformat(),
            'is_active': device.is_active,
        })
    
    # Export preferences
    try:
        prefs = UserPreferences.objects.get(device_id=device_id)
        data['preferences'] = {
            'alert_radius': prefs.alert_radius,
            'default_zoom': prefs.default_zoom,
            'push_notifications': prefs.push_notifications,
            'proximity_alerts': prefs.proximity_alerts,
            'sound_vibration': prefs.sound_vibration,
            'anonymous_reporting': prefs.anonymous_reporting,
            'created_at': prefs.created_at.isoformat(),
            'updated_at': prefs.updated_at.isoformat(),
        }
    except UserPreferences.DoesNotExist:
        pass
    
    # Export safe zones
    zones = SafeZone.objects.filter(device_id=device_id)
    for zone in zones:
        data['safe_zones'].append({
            'name': zone.name,
            'zone_type': zone.zone_type,
            'latitude': zone.latitude,
            'longitude': zone.longitude,
            'radius': zone.radius,
            'is_active': zone.is_active,
            'created_at': zone.created_at.isoformat(),
        })
    
    return data
