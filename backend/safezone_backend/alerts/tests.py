from django.test import TestCase
from django.utils import timezone
from datetime import timedelta
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
