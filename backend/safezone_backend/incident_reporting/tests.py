from django.test import TestCase, override_settings
from rest_framework.test import APIClient
from rest_framework import status
from .models import Incident
from alerts.models import Alert


@override_settings(DEBUG=True, AUTH0_DOMAIN='')
class IncidentAlertGenerationTestCase(TestCase):
    """Test that alerts are automatically generated when incidents are created."""
    
    def setUp(self):
        self.client = APIClient()
    
    def test_alert_created_on_incident_creation(self):
        """Test that an alert is automatically created when an incident is reported."""
        # Create an incident via API
        incident_data = {
            'category': 'theft',
            'latitude': 37.7749,
            'longitude': -122.4194,
            'title': 'Test Theft Incident',
            'description': 'Test description',
            'notify_nearby': True
        }
        
        response = self.client.post(
            '/api/incidents/',
            incident_data,
            format='json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Verify incident was created
        incident = Incident.objects.first()
        self.assertIsNotNone(incident)
        self.assertEqual(incident.category, 'theft')
        
        # Verify alert was created
        alert = Alert.objects.filter(incident=incident).first()
        self.assertIsNotNone(alert, "Alert should be created when incident is reported")
        self.assertEqual(alert.incident, incident)
        self.assertEqual(alert.alert_type, 'theft')
        self.assertEqual(alert.severity, 'high')
        self.assertIn('Theft', alert.title)
    
    def test_multiple_incidents_create_multiple_alerts(self):
        """Test that multiple incidents generate multiple alerts."""
        incidents_data = [
            {
                'category': 'assault',
                'latitude': 37.7749,
                'longitude': -122.4194,
                'title': 'Test Assault',
            },
            {
                'category': 'fire',
                'latitude': 37.7750,
                'longitude': -122.4195,
                'title': 'Test Fire',
            },
        ]
        
        for incident_data in incidents_data:
            response = self.client.post(
                '/api/incidents/',
                incident_data,
                format='json'
            )
            self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Verify both incidents and alerts were created
        self.assertEqual(Incident.objects.count(), 2)
        self.assertEqual(Alert.objects.count(), 2)
        
        # Verify each incident has an associated alert
        for incident in Incident.objects.all():
            alert = Alert.objects.filter(incident=incident).first()
            self.assertIsNotNone(alert)
    
    def test_alert_severity_matches_incident_category(self):
        """Test that alert severity is correctly mapped from incident category."""
        test_cases = [
            ('assault', 'high'),
            ('theft', 'high'),
            ('harassment', 'medium'),
            ('lighting', 'low'),
            ('powerOutage', 'info'),
        ]
        
        for category, expected_severity in test_cases:
            incident_data = {
                'category': category,
                'latitude': 37.7749,
                'longitude': -122.4194,
                'title': f'Test {category}',
            }
            
            response = self.client.post(
                '/api/incidents/',
                incident_data,
                format='json'
            )
            
            self.assertEqual(response.status_code, status.HTTP_201_CREATED)
            
            incident = Incident.objects.latest('timestamp')
            alert = Alert.objects.filter(incident=incident).first()
            
            self.assertIsNotNone(alert)
            self.assertEqual(
                alert.severity,
                expected_severity,
                f"Alert severity for {category} should be {expected_severity}"
            )
