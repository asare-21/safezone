from django.db import models


class EmergencyService(models.Model):
    """Model to store emergency services by country."""
    
    SERVICE_TYPE_CHOICES = [
        ('police', 'Police Station'),
        ('hospital', 'Hospital'),
        ('fireStation', 'Fire Station'),
        ('ambulance', 'Ambulance'),
    ]
    
    # Service identification
    country_code = models.CharField(
        max_length=2,
        db_index=True,
        help_text='ISO 3166-1 alpha-2 country code (e.g., US, GH, NG)',
    )
    name = models.CharField(max_length=200)
    service_type = models.CharField(
        max_length=20,
        choices=SERVICE_TYPE_CHOICES,
        db_index=True,
    )
    
    # Contact information
    phone_number = models.CharField(max_length=50)
    
    # Location information
    latitude = models.FloatField()
    longitude = models.FloatField()
    address = models.CharField(max_length=500, blank=True, null=True)
    
    # Additional details
    hours = models.CharField(
        max_length=100,
        blank=True,
        null=True,
        help_text='Operating hours (e.g., "24/7", "9AM-5PM")',
    )
    
    # Metadata
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['country_code', 'service_type', 'name']
        indexes = [
            models.Index(fields=['country_code', 'service_type']),
            models.Index(fields=['is_active']),
            models.Index(fields=['latitude', 'longitude']),
        ]
    
    def __str__(self):
        return f"{self.name} ({self.country_code}) - {self.get_service_type_display()}"
