from django.test import TestCase
from django.utils import timezone
from datetime import timedelta
from unittest.mock import patch, MagicMock
from .models import Alert
from incident_reporting.models import Incident


class AlertModelTest(TestCase):
    """Tests for the Alert model."""

    def setUp(self):
        """Set up test data."""
        # Create a test incident
        self.incident = Incident.objects.create(
            category='assault',
            latitude=37.7749,
            longitude=-122.4194,
            title='Test Assault Incident',
            description='Test description',
            confirmed_by=1,
            notify_nearby=True,
        )

    def test_alert_creation(self):
        """Test creating an alert."""
        alert = Alert.objects.create(
            incident=self.incident,
            alert_type='highRisk',
            severity='high',
            title='Test Alert',
            location='37.7749, -122.4194',
            confirmed_by=1,
        )
        
        self.assertEqual(alert.incident, self.incident)
        self.assertEqual(alert.alert_type, 'highRisk')
        self.assertEqual(alert.severity, 'high')
        self.assertEqual(alert.title, 'Test Alert')
        self.assertIsNotNone(alert.timestamp)

    def test_generate_alert_from_incident(self):
        """Test generating an alert from an incident."""
        # Mock the geocoding to avoid external API calls in tests
        with patch.object(Alert, 'reverse_geocode') as mock_geocode:
            mock_geocode.return_value = 'Market St, Downtown, San Francisco'
            
            alert = Alert.generate_alert_from_incident(
                self.incident,
                distance_meters=500.0,
            )
            
            self.assertEqual(alert.incident, self.incident)
            self.assertEqual(alert.severity, 'high')  # assault maps to high
            self.assertEqual(alert.alert_type, 'highRisk')
            self.assertEqual(alert.confirmed_by, 1)
            self.assertEqual(alert.distance_meters, 500.0)
            self.assertIn('Assault', alert.title)
            # Verify geocoding was called with incident coordinates
            mock_geocode.assert_called_once_with(
                self.incident.latitude,
                self.incident.longitude,
            )

    def test_alert_ordering(self):
        """Test that alerts are ordered by timestamp (newest first)."""
        # Create alerts at different times
        alert1 = Alert.objects.create(
            incident=self.incident,
            alert_type='highRisk',
            severity='high',
            title='Alert 1',
            location='Test location',
        )
        
        # Manually set timestamp for older alert
        alert2 = Alert.objects.create(
            incident=self.incident,
            alert_type='theft',
            severity='medium',
            title='Alert 2',
            location='Test location',
        )
        alert2.timestamp = timezone.now() - timedelta(hours=1)
        alert2.save()
        
        alerts = list(Alert.objects.all())
        self.assertEqual(alerts[0].id, alert1.id)  # Newest first
        self.assertEqual(alerts[1].id, alert2.id)

    def test_alert_severity_mapping(self):
        """Test that incident categories map to correct severities."""
        test_cases = [
            ('assault', 'high'),
            ('theft', 'high'),
            ('fire', 'high'),
            ('harassment', 'medium'),
            ('suspicious', 'medium'),
            ('lighting', 'low'),
            ('powerOutage', 'info'),
        ]
        
        # Mock geocoding for all test cases
        with patch.object(Alert, 'reverse_geocode') as mock_geocode:
            mock_geocode.return_value = 'Test Location'
            
            for category, expected_severity in test_cases:
                incident = Incident.objects.create(
                    category=category,
                    latitude=37.7749,
                    longitude=-122.4194,
                    title=f'Test {category}',
                )
                
                alert = Alert.generate_alert_from_incident(incident)
                self.assertEqual(
                    alert.severity,
                    expected_severity,
                    f'Category {category} should map to severity {expected_severity}',
                )

    def test_alert_string_representation(self):
        """Test the string representation of an alert."""
        alert = Alert.objects.create(
            incident=self.incident,
            alert_type='highRisk',
            severity='high',
            title='Test Alert',
            location='Test location',
        )
        
        self.assertIn('HIGH', str(alert))
        self.assertIn('Test Alert', str(alert))

    def test_reverse_geocode_success(self):
        """Test successful reverse geocoding."""
        with patch('alerts.models.get_geolocator') as mock_get_geolocator:
            # Mock the geolocator and its response
            mock_geolocator = MagicMock()
            mock_get_geolocator.return_value = mock_geolocator
            
            # Create a mock location with address data
            mock_location = MagicMock()
            mock_location.raw = {
                'address': {
                    'road': 'Market Street',
                    'neighbourhood': 'Financial District',
                    'city': 'San Francisco',
                }
            }
            mock_geolocator.reverse.return_value = mock_location
            
            result = Alert.reverse_geocode(37.7749, -122.4194)
            
            self.assertEqual(result, 'Market Street, Financial District, San Francisco')
            mock_geolocator.reverse.assert_called_once()

    def test_reverse_geocode_fallback_on_error(self):
        """Test that reverse geocoding falls back to coordinates on error."""
        with patch('alerts.models.get_geolocator') as mock_get_geolocator:
            mock_geolocator = MagicMock()
            mock_get_geolocator.return_value = mock_geolocator
            
            # Simulate a geocoding timeout
            from geopy.exc import GeocoderTimedOut
            mock_geolocator.reverse.side_effect = GeocoderTimedOut()
            
            result = Alert.reverse_geocode(37.7749, -122.4194)
            
            # Should fallback to coordinates
            self.assertEqual(result, '37.774900, -122.419400')

    def test_reverse_geocode_partial_address(self):
        """Test reverse geocoding with partial address data."""
        with patch('alerts.models.get_geolocator') as mock_get_geolocator:
            mock_geolocator = MagicMock()
            mock_get_geolocator.return_value = mock_geolocator
            
            # Mock location with only city
            mock_location = MagicMock()
            mock_location.raw = {
                'address': {
                    'city': 'San Francisco',
                }
            }
            mock_geolocator.reverse.return_value = mock_location
            
            result = Alert.reverse_geocode(37.7749, -122.4194)
            
            self.assertEqual(result, 'San Francisco')

    def test_reverse_geocode_no_address(self):
        """Test reverse geocoding when no address is found."""
        with patch('alerts.models.get_geolocator') as mock_get_geolocator:
            mock_geolocator = MagicMock()
            mock_get_geolocator.return_value = mock_geolocator
            
            # Mock location with no address
            mock_location = MagicMock()
            mock_location.raw = {}
            mock_geolocator.reverse.return_value = mock_location
            
            result = Alert.reverse_geocode(37.7749, -122.4194)
            
            # Should fallback to coordinates
            self.assertEqual(result, '37.774900, -122.419400')
