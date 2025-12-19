from django.db import models
from django.contrib.auth.models import User


class UserDevice(models.Model):
    """Model to store user's Firebase Cloud Messaging tokens for push notifications."""
    
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='devices',
        null=True,
        blank=True,
    )
    device_id = models.CharField(max_length=255, unique=True)
    fcm_token = models.TextField()
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

    def __str__(self):
        return f"{self.device_id} - {self.platform}"


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
    device_id = models.CharField(max_length=255)  # For anonymous users
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
            models.Index(fields=['device_id', 'is_active']),
            models.Index(fields=['latitude', 'longitude']),
        ]

    def __str__(self):
        return f"{self.name} ({self.zone_type})"

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
    
    device_id = models.CharField(max_length=255, unique=True, db_index=True)
    
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
    
    def __str__(self):
        return f"Preferences for {self.device_id}"
