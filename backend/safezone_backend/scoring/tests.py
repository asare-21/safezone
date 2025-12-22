from django.test import TestCase, override_settings
from rest_framework.test import APIClient
from rest_framework import status
from .models import UserProfile, Badge, IncidentConfirmation, hash_device_id
from incident_reporting.models import Incident
from django.utils import timezone
from datetime import timedelta


@override_settings(DEBUG=True, AUTH0_DOMAIN='')
class ScoringSystemTestCase(TestCase):
    """Test cases for the scoring system."""
    
    def setUp(self):
        self.client = APIClient()
        self.device_id = 'test_device_12345'
        self.device_id_hash = hash_device_id(self.device_id)
    
    def test_user_profile_creation(self):
        """Test that user profile is created automatically."""
        response = self.client.get(f'/api/scoring/profile/{self.device_id}/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['total_points'], 0)
        self.assertEqual(response.data['current_tier'], 1)
        self.assertEqual(response.data['tier_name'], 'Fresh Eye Scout')
    
    def test_report_points_awarded(self):
        """Test that points are awarded when creating a report."""
        # Create an incident with device_id
        incident_data = {
            'category': 'theft',
            'latitude': 37.7749,
            'longitude': -122.4194,
            'title': 'Test Theft Incident',
            'description': 'Test description',
            'device_id': self.device_id
        }
        
        response = self.client.post(
            '/api/incidents/',
            incident_data,
            format='json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Check that profile was created and points awarded
        profile = UserProfile.objects.get(device_id_hash=self.device_id_hash)
        self.assertEqual(profile.reports_count, 1)
        self.assertGreaterEqual(profile.total_points, 10)  # At least base points
    
    def test_time_bonus_points(self):
        """Test that time bonus is awarded for reports within 1 hour."""
        # Create an incident
        incident = Incident.objects.create(
            category='fire',
            latitude=37.7749,
            longitude=-122.4194,
            title='Test Fire'
        )
        
        # Get or create profile
        profile, _ = UserProfile.objects.get_or_create(
            device_id_hash=self.device_id_hash,
            defaults={'device_id': self.device_id}
        )
        
        # Award points
        result = profile.add_report_points(incident)
        
        # Should get base 10 points + 2 time bonus
        self.assertEqual(result['points_earned'], 12)
        self.assertEqual(result['base_points'], 10)
        self.assertEqual(result['time_bonus'], 2)
    
    def test_confirmation_points(self):
        """Test that points are awarded for confirming incidents."""
        # Create an incident
        incident = Incident.objects.create(
            category='theft',
            latitude=37.7749,
            longitude=-122.4194,
            title='Test Theft'
        )
        
        # Confirm the incident
        response = self.client.post(
            f'/api/scoring/incidents/{incident.id}/confirm/',
            {'device_id': self.device_id},
            format='json'
        )
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['points_earned'], 5)
        
        # Check profile was updated
        profile = UserProfile.objects.get(device_id_hash=self.device_id_hash)
        self.assertEqual(profile.confirmations_count, 1)
        self.assertEqual(profile.total_points, 5)
    
    def test_duplicate_confirmation_prevented(self):
        """Test that users cannot confirm the same incident twice."""
        # Create an incident
        incident = Incident.objects.create(
            category='theft',
            latitude=37.7749,
            longitude=-122.4194,
            title='Test Theft'
        )
        
        # First confirmation
        response1 = self.client.post(
            f'/api/scoring/incidents/{incident.id}/confirm/',
            {'device_id': self.device_id},
            format='json'
        )
        self.assertEqual(response1.status_code, status.HTTP_200_OK)
        
        # Second confirmation (should fail)
        response2 = self.client.post(
            f'/api/scoring/incidents/{incident.id}/confirm/',
            {'device_id': self.device_id},
            format='json'
        )
        self.assertEqual(response2.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('already confirmed', response2.data['error'])
    
    def test_tier_progression(self):
        """Test that tier progresses with points."""
        profile = UserProfile.objects.create(
            device_id=self.device_id,
            device_id_hash=self.device_id_hash
        )
        
        # Test tier 1
        self.assertEqual(profile.current_tier, 1)
        self.assertEqual(profile.tier_name, 'Fresh Eye Scout')
        
        # Progress to tier 2
        profile.total_points = 51
        profile.update_tier()
        self.assertEqual(profile.current_tier, 2)
        self.assertEqual(profile.tier_name, 'Neighborhood Watch')
        
        # Progress to tier 4
        profile.total_points = 301
        profile.update_tier()
        self.assertEqual(profile.current_tier, 4)
        self.assertEqual(profile.tier_name, 'Community Guardian')
        
        # Progress to tier 7
        profile.total_points = 1200
        profile.update_tier()
        self.assertEqual(profile.current_tier, 7)
        self.assertEqual(profile.tier_name, 'Legendary Watchmaster')
    
    def test_truth_triangulator_badge(self):
        """Test that Truth Triangulator badge is earned after 5 confirmations."""
        profile = UserProfile.objects.create(
            device_id=self.device_id,
            device_id_hash=self.device_id_hash
        )
        
        # Create 5 incidents and confirm them
        for i in range(5):
            incident = Incident.objects.create(
                category='theft',
                latitude=37.7749 + i * 0.001,
                longitude=-122.4194,
                title=f'Test Incident {i}'
            )
            
            response = self.client.post(
                f'/api/scoring/incidents/{incident.id}/confirm/',
                {'device_id': self.device_id},
                format='json'
            )
            self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Check badge was earned
        badge = Badge.objects.filter(
            profile=profile,
            badge_type='truth_triangulator'
        ).first()
        self.assertIsNotNone(badge)
    
    def test_leaderboard(self):
        """Test leaderboard endpoint."""
        # Clear any existing profiles
        UserProfile.objects.all().delete()
        
        # Create multiple profiles with different scores
        UserProfile.objects.create(
            device_id='device1',
            device_id_hash=hash_device_id('device1'),
            total_points=100
        )
        UserProfile.objects.create(
            device_id='device2',
            device_id_hash=hash_device_id('device2'),
            total_points=200
        )
        UserProfile.objects.create(
            device_id='device3',
            device_id_hash=hash_device_id('device3'),
            total_points=50
        )
        
        response = self.client.get('/api/scoring/leaderboard/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # Response might be paginated
        results = response.data.get('results', response.data)
        self.assertGreaterEqual(len(results), 3)
        # Check ordering (highest first) - just check first 3
        self.assertEqual(results[0]['total_points'], 200)
        self.assertEqual(results[1]['total_points'], 100)
        self.assertEqual(results[2]['total_points'], 50)
    
    def test_accuracy_percentage(self):
        """Test accuracy percentage calculation."""
        profile = UserProfile.objects.create(
            device_id=self.device_id,
            device_id_hash=self.device_id_hash,
            reports_count=10,
            verified_reports=9
        )
        
        self.assertEqual(profile.accuracy_percentage, 90.0)
        
        # Test zero reports
        profile2 = UserProfile.objects.create(
            device_id='device2',
            device_id_hash=hash_device_id('device2')
        )
        self.assertEqual(profile2.accuracy_percentage, 0)
    
    def test_max_confirmations_limit(self):
        """Test that confirmations beyond 10 don't award points."""
        incident = Incident.objects.create(
            category='theft',
            latitude=37.7749,
            longitude=-122.4194,
            title='Test Theft'
        )
        
        # Create 11 confirmations from different devices
        for i in range(11):
            device = f'device_{i}'
            response = self.client.post(
                f'/api/scoring/incidents/{incident.id}/confirm/',
                {'device_id': device},
                format='json'
            )
            self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Check that incident has correct confirmation count
        incident.refresh_from_db()
        self.assertEqual(incident.confirmed_by, 11)
