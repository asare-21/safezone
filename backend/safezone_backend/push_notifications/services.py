"""
Firebase Cloud Messaging service for sending push notifications.
"""
import os
import logging
from typing import List, Optional
import firebase_admin
from firebase_admin import credentials, messaging

logger = logging.getLogger(__name__)


class FirebaseMessagingService:
    """Service for sending push notifications via Firebase Cloud Messaging."""
    
    _initialized = False
    
    @classmethod
    def initialize(cls):
        """Initialize Firebase Admin SDK with service account credentials."""
        if cls._initialized:
            return
        
        try:
            # Check if credentials file path is set
            cred_path = os.environ.get('FIREBASE_CREDENTIALS_PATH')
            
            if cred_path and os.path.exists(cred_path):
                cred = credentials.Certificate(cred_path)
                firebase_admin.initialize_app(cred)
                cls._initialized = True
                logger.info("Firebase Admin SDK initialized successfully")
            else:
                logger.warning(
                    "Firebase credentials not found. Set FIREBASE_CREDENTIALS_PATH "
                    "environment variable to enable push notifications."
                )
        except Exception as e:
            logger.error(f"Failed to initialize Firebase Admin SDK: {e}")
    
    @classmethod
    def send_incident_notification(
        cls,
        fcm_tokens: List[str],
        incident_data: dict,
    ) -> dict:
        """
        Send incident notification to multiple devices.
        
        Args:
            fcm_tokens: List of FCM registration tokens
            incident_data: Dictionary containing incident details
            
        Returns:
            Dictionary with success count and failed tokens
        """
        if not cls._initialized:
            cls.initialize()
        
        if not cls._initialized:
            logger.warning("Firebase not initialized, skipping notification")
            return {'success': 0, 'failed': len(fcm_tokens)}
        
        if not fcm_tokens:
            return {'success': 0, 'failed': 0}
        
        # Create notification message
        category = incident_data.get('category', 'incident')
        title = incident_data.get('title', 'New Safety Incident')
        description = incident_data.get('description', '')
        
        # Format notification
        notification = messaging.Notification(
            title=f"⚠️ {category.capitalize()} Reported Nearby",
            body=f"{title[:100]}" if title else description[:100],
        )
        
        # Add data payload
        data = {
            'incident_id': str(incident_data.get('id', '')),
            'category': category,
            'latitude': str(incident_data.get('latitude', '')),
            'longitude': str(incident_data.get('longitude', '')),
            'timestamp': incident_data.get('timestamp', ''),
            'type': 'incident_alert',
        }
        
        success_count = 0
        failed_tokens = []
        
        # Send to each device
        for token in fcm_tokens:
            try:
                message = messaging.Message(
                    notification=notification,
                    data=data,
                    token=token,
                    android=messaging.AndroidConfig(
                        priority='high',
                        notification=messaging.AndroidNotification(
                            icon='ic_notification',
                            color='#FF3B30',
                            sound='default',
                        ),
                    ),
                    apns=messaging.APNSConfig(
                        payload=messaging.APNSPayload(
                            aps=messaging.Aps(
                                sound='default',
                                badge=1,
                            ),
                        ),
                    ),
                )
                
                response = messaging.send(message)
                logger.info(f"Successfully sent notification: {response}")
                success_count += 1
                
            except Exception as e:
                logger.error(f"Failed to send notification to {token[:20]}...: {e}")
                failed_tokens.append(token)
        
        return {
            'success': success_count,
            'failed': len(failed_tokens),
            'failed_tokens': failed_tokens,
        }
    
    @classmethod
    def send_to_topic(cls, topic: str, incident_data: dict) -> bool:
        """
        Send notification to a topic (for future use).
        
        Args:
            topic: Topic name (e.g., 'incidents_nearby')
            incident_data: Dictionary containing incident details
            
        Returns:
            True if successful, False otherwise
        """
        if not cls._initialized:
            cls.initialize()
        
        if not cls._initialized:
            return False
        
        try:
            category = incident_data.get('category', 'incident')
            title = incident_data.get('title', 'New Safety Incident')
            
            message = messaging.Message(
                notification=messaging.Notification(
                    title=f"⚠️ {category.capitalize()} Reported Nearby",
                    body=title[:100],
                ),
                data={
                    'incident_id': str(incident_data.get('id', '')),
                    'category': category,
                    'type': 'incident_alert',
                },
                topic=topic,
            )
            
            response = messaging.send(message)
            logger.info(f"Successfully sent to topic {topic}: {response}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to send to topic {topic}: {e}")
            return False
