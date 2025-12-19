"""
Utilities for filtering users based on safe zones and incident locations.
"""
import logging
from typing import List, Tuple
from user_settings.models import UserDevice, SafeZone

logger = logging.getLogger(__name__)


def get_devices_to_notify(incident_latitude: float, incident_longitude: float) -> List[Tuple[str, str]]:
    """
    Get list of device IDs and FCM tokens that should be notified about an incident.
    
    Only notifies users if:
    1. They have safe zones configured AND
    2. The incident is within at least one of their active safe zones
    
    Args:
        incident_latitude: Latitude of the incident
        incident_longitude: Longitude of the incident
        
    Returns:
        List of tuples (device_id, fcm_token) for devices to notify
    """
    devices_to_notify = []
    
    try:
        # Get all active safe zones
        active_safe_zones = SafeZone.objects.filter(is_active=True)
        
        # Track which device IDs have matching safe zones
        matching_device_ids = set()
        
        for safe_zone in active_safe_zones:
            # Check if incident is within this safe zone
            if safe_zone.contains_point(incident_latitude, incident_longitude):
                matching_device_ids.add(safe_zone.device_id)
                logger.info(
                    f"Incident within safe zone '{safe_zone.name}' "
                    f"for device {safe_zone.device_id}"
                )
        
        # Get FCM tokens for matching devices
        if matching_device_ids:
            devices = UserDevice.objects.filter(
                device_id__in=matching_device_ids,
                is_active=True,
            ).values_list('device_id', 'fcm_token')
            
            devices_to_notify = list(devices)
            logger.info(
                f"Found {len(devices_to_notify)} devices to notify "
                f"based on safe zone matching"
            )
        else:
            logger.info(
                "No safe zones contain this incident location - "
                "no notifications will be sent"
            )
    
    except Exception as e:
        logger.error(f"Error filtering devices by safe zones: {e}")
    
    return devices_to_notify


def send_incident_notifications(incident):
    """
    Send push notifications for a new incident to users with matching safe zones.
    
    Args:
        incident: Incident model instance
    """
    from push_notifications.services import FirebaseMessagingService
    from push_notifications.models import NotificationLog
    
    try:
        # Get devices that should be notified
        devices = get_devices_to_notify(incident.latitude, incident.longitude)
        
        if not devices:
            logger.info(
                f"No users to notify for incident {incident.id} - "
                f"either no safe zones configured or incident not within any safe zones"
            )
            return
        
        # Extract FCM tokens
        fcm_tokens = [token for _, token in devices]
        
        # Prepare incident data
        incident_data = {
            'id': incident.id,
            'category': incident.category,
            'latitude': incident.latitude,
            'longitude': incident.longitude,
            'title': incident.title,
            'description': incident.description or '',
            'timestamp': incident.timestamp.isoformat(),
        }
        
        # Send notifications
        logger.info(f"Sending notifications to {len(fcm_tokens)} devices")
        result = FirebaseMessagingService.send_incident_notification(
            fcm_tokens=fcm_tokens,
            incident_data=incident_data,
        )
        
        # Log notification results
        for device_id, fcm_token in devices:
            is_success = fcm_token not in result.get('failed_tokens', [])
            
            NotificationLog.objects.create(
                incident=incident,
                device_id=device_id,
                fcm_token=fcm_token,
                success=is_success,
                error_message=None if is_success else "Failed to send",
            )
        
        logger.info(
            f"Notification results for incident {incident.id}: "
            f"{result['success']} successful, {result['failed']} failed"
        )
    
    except Exception as e:
        logger.error(f"Error sending incident notifications: {e}")
