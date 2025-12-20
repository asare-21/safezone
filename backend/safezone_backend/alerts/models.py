from django.db import models
from incident_reporting.models import Incident


class Alert(models.Model):
    """
    Model for proximity alerts generated when users approach incident locations.
    Alerts are created based on user location and incident proximity.
    """
    
    SEVERITY_CHOICES = [
        ('high', 'High'),
        ('medium', 'Medium'),
        ('low', 'Low'),
        ('info', 'Info'),
    ]
    
    TYPE_CHOICES = [
        ('highRisk', 'High Risk'),
        ('theft', 'Theft'),
        ('eventCrowd', 'Event Crowd'),
        ('trafficCleared', 'Traffic Cleared'),
    ]
    
    id = models.AutoField(primary_key=True)
    incident = models.ForeignKey(
        Incident,
        on_delete=models.CASCADE,
        related_name='alerts',
        help_text='The incident that triggered this alert'
    )
    alert_type = models.CharField(
        max_length=50,
        choices=TYPE_CHOICES,
        default='highRisk'
    )
    severity = models.CharField(
        max_length=20,
        choices=SEVERITY_CHOICES,
        default='medium'
    )
    title = models.CharField(max_length=200)
    location = models.CharField(max_length=255)
    timestamp = models.DateTimeField(auto_now_add=True)
    confirmed_by = models.IntegerField(default=0, blank=True, null=True)
    distance_meters = models.FloatField(
        null=True,
        blank=True,
        help_text='Distance from user location in meters'
    )
    
    class Meta:
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['-timestamp']),
            models.Index(fields=['severity']),
            models.Index(fields=['alert_type']),
        ]
    
    def __str__(self):
        return f"{self.severity.upper()} - {self.title}"
    
    @classmethod
    def generate_alert_from_incident(cls, incident, distance_meters=None):
        """
        Generate an alert from an incident.
        
        Args:
            incident: The Incident object to create an alert from
            distance_meters: Optional distance from user location
            
        Returns:
            Alert object
        """
        # Determine severity based on incident category
        severity_map = {
            'assault': 'high',
            'theft': 'high',
            'fire': 'high',
            'weaponSighting': 'high',
            'medicalEmergency': 'high',
            'naturalDisaster': 'high',
            'harassment': 'medium',
            'suspicious': 'medium',
            'vandalism': 'medium',
            'drugActivity': 'medium',
            'roadHazard': 'medium',
            'accident': 'medium',
            'trespassing': 'low',
            'lighting': 'low',
            'powerOutage': 'info',
            'waterIssue': 'info',
            'noise': 'info',
            'animalDanger': 'low',
        }
        
        # Determine alert type based on category
        type_map = {
            'assault': 'highRisk',
            'theft': 'theft',
            'suspicious': 'highRisk',
            'fire': 'highRisk',
            'weaponSighting': 'highRisk',
            'accident': 'trafficCleared',
        }
        
        severity = severity_map.get(incident.category, 'info')
        alert_type = type_map.get(incident.category, 'highRisk')
        
        # Generate location string
        location = f"{incident.latitude:.6f}, {incident.longitude:.6f}"
        
        # Create alert title based on incident
        title = f"{incident.get_category_display()} Reported Nearby"
        
        return cls.objects.create(
            incident=incident,
            alert_type=alert_type,
            severity=severity,
            title=title,
            location=location,
            confirmed_by=incident.confirmed_by,
            distance_meters=distance_meters,
        )
