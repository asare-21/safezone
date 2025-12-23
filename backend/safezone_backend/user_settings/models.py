from django.db import models
from django.contrib.auth.models import User
from encrypted_model_fields.fields import EncryptedCharField, EncryptedTextField
import hashlib


def hash_device_id(device_id):
    """Create a consistent hash of device_id for lookups."""
    return hashlib.sha256(device_id.encode()).hexdigest()


class UserDevice(models.Model):
    """Model to store user's Firebase Cloud Messaging tokens for push notifications."""
    
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='devices',
        null=True,
        blank=True,
    )
    # Encrypted fields for sensitive data
    device_id = EncryptedCharField(max_length=255, unique=True)
    device_id_hash = models.CharField(max_length=64, db_index=True, default='')
    fcm_token = EncryptedTextField()
    
    platform = models.CharField(
        max_length=10,
        choices=[('android', 'Android'), ('ios', 'iOS'), ('web', 'Web')],
        default='android',
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        ordering = ['-updated_at']
        indexes = [
            models.Index(fields=['device_id_hash']),
        ]

    def __str__(self):
        return f"{self.device_id} - {self.platform}"
    
    def save(self, *args, **kwargs):
        """Generate device_id_hash on save."""
        if self.device_id:
            self.device_id_hash = hash_device_id(str(self.device_id))
        super().save(*args, **kwargs)


class SafeZone(models.Model):
    """Model to store user-defined safe zones."""
    
    ZONE_TYPE_CHOICES = [
        ('home', 'Home'),
        ('work', 'Work'),
        ('school', 'School'),
        ('custom', 'Custom'),
    ]
    
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='safe_zones',
        null=True,
        blank=True,
    )
    # Encrypted device_id for anonymous users
    device_id = EncryptedCharField(max_length=255)
    # Hash of device_id for efficient lookups
    device_id_hash = models.CharField(max_length=64, db_index=True, default='')
    name = models.CharField(max_length=200)
    latitude = models.FloatField()
    longitude = models.FloatField()
    radius = models.FloatField(help_text='Radius in meters')
    zone_type = models.CharField(
        max_length=10,
        choices=ZONE_TYPE_CHOICES,
        default='custom',
    )
    is_active = models.BooleanField(default=True)
    notify_on_enter = models.BooleanField(default=True)
    notify_on_exit = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['is_active']),
            models.Index(fields=['latitude', 'longitude']),
            models.Index(fields=['device_id_hash']),
        ]

    def __str__(self):
        return f"{self.name} ({self.zone_type})"
    
    def save(self, *args, **kwargs):
        """Generate device_id_hash on save."""
        if self.device_id:
            self.device_id_hash = hash_device_id(str(self.device_id))
        super().save(*args, **kwargs)

    def contains_point(self, latitude, longitude):
        """Check if a point is within this safe zone using Haversine formula."""
        from math import radians, sin, cos, sqrt, atan2
        
        # Radius of Earth in meters
        R = 6371000
        
        lat1 = radians(self.latitude)
        lat2 = radians(latitude)
        delta_lat = radians(latitude - self.latitude)
        delta_lon = radians(longitude - self.longitude)
        
        a = (sin(delta_lat / 2) ** 2 +
             cos(lat1) * cos(lat2) * sin(delta_lon / 2) ** 2)
        c = 2 * atan2(sqrt(a), sqrt(1 - a))
        
        distance = R * c
        
        return distance <= self.radius


class UserPreferences(models.Model):
    """Model to store user preferences and settings."""
    
    # Encrypted device_id for privacy
    device_id = EncryptedCharField(max_length=255, unique=True, db_index=True)
    device_id_hash = models.CharField(max_length=64, db_index=True, default='')
    
    # Map Settings
    alert_radius = models.FloatField(default=5.0, help_text='Alert radius in kilometers')
    default_zoom = models.FloatField(default=15.0, help_text='Default map zoom level')
    location_icon = models.CharField(max_length=255, default='assets/fun_icons/icon1.png')
    
    # Notification Settings
    push_notifications = models.BooleanField(default=True)
    proximity_alerts = models.BooleanField(default=True)
    sound_vibration = models.BooleanField(default=True)
    
    # Privacy Settings
    anonymous_reporting = models.BooleanField(default=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-updated_at']
        verbose_name = 'User Preference'
        verbose_name_plural = 'User Preferences'
        indexes = [
            models.Index(fields=['device_id_hash']),
        ]
    
    def __str__(self):
        return f"Preferences for {self.device_id}"
    
    def save(self, *args, **kwargs):
        """Generate device_id_hash on save."""
        if self.device_id:
            self.device_id_hash = hash_device_id(str(self.device_id))
        super().save(*args, **kwargs)
