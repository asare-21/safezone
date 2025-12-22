from django.db import models
from incident_reporting.models import Incident
from geopy.geocoders import Nominatim
from geopy.exc import GeocoderTimedOut, GeocoderServiceError
import logging

logger = logging.getLogger(__name__)

# Module-level geolocator instance for reuse across requests
_geolocator = None

def get_geolocator():
    """Get or create the Nominatim geolocator instance."""
    global _geolocator
    if _geolocator is None:
        _geolocator = Nominatim(user_agent="safezone_app", timeout=3)
    return _geolocator


class Alert(models.Model):
    """
    Model for proximity alerts generated when users approach incident locations.
    Alerts are created based on user location and incident proximity.
    """
    
    # Maximum number of address components to include in simplified addresses
    MAX_ADDRESS_PARTS = 3
    
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
    
    @staticmethod
    def reverse_geocode(latitude, longitude):
        """
        Reverse geocode coordinates to get a simplified street address.
        
        Args:
            latitude: Latitude coordinate
            longitude: Longitude coordinate
            
        Returns:
            Simplified street address or formatted coordinates if geocoding fails
        """
        try:
            # Get the shared geolocator instance
            geolocator = get_geolocator()
            
            # Reverse geocode the coordinates
            location = geolocator.reverse(f"{latitude}, {longitude}", language='en')
            
            if location and location.raw.get('address'):
                address = location.raw['address']
                
                # Build simplified address from available components
                address_parts = []
                
                # Try to get street information
                if 'road' in address:
                    address_parts.append(address['road'])
                elif 'pedestrian' in address:
                    address_parts.append(address['pedestrian'])
                
                # Add neighborhood or suburb
                if 'neighbourhood' in address:
                    address_parts.append(address['neighbourhood'])
                elif 'suburb' in address:
                    address_parts.append(address['suburb'])
                elif 'city_district' in address:
                    address_parts.append(address['city_district'])
                
                # Add city or town
                if 'city' in address:
                    address_parts.append(address['city'])
                elif 'town' in address:
                    address_parts.append(address['town'])
                elif 'village' in address:
                    address_parts.append(address['village'])
                
                # Return simplified address if we have components
                if address_parts:
                    return ', '.join(address_parts[:Alert.MAX_ADDRESS_PARTS])
            
            # Fallback to coordinates if address not found
            return f"{latitude:.6f}, {longitude:.6f}"
            
        except (GeocoderTimedOut, GeocoderServiceError) as e:
            logger.warning(f"Geocoding service error for ({latitude}, {longitude}): {e}")
            return f"{latitude:.6f}, {longitude:.6f}"
        except Exception as e:
            logger.error(f"Unexpected error during geocoding for ({latitude}, {longitude}): {e}")
            return f"{latitude:.6f}, {longitude:.6f}"
    
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
        
        # Generate location string using reverse geocoding
        location = cls.reverse_geocode(incident.latitude, incident.longitude)
        
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
