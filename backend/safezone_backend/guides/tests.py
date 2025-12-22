from django.test import TestCase, override_settings
from rest_framework.test import APITestCase
from rest_framework import status
from .models import Guide


class GuideModelTest(TestCase):
    """Tests for the Guide model."""

    def test_guide_creation(self):
        """Test creating a guide."""
        guide = Guide.objects.create(
            section='how_it_works',
            title='Test Guide',
            content='Test content for the guide',
            icon='info',
            order=1,
            is_active=True,
        )
        
        self.assertEqual(guide.section, 'how_it_works')
        self.assertEqual(guide.title, 'Test Guide')
        self.assertEqual(guide.content, 'Test content for the guide')
        self.assertEqual(guide.icon, 'info')
        self.assertEqual(guide.order, 1)
        self.assertTrue(guide.is_active)
        self.assertIsNotNone(guide.created_at)
        self.assertIsNotNone(guide.updated_at)

    def test_guide_string_representation(self):
        """Test the string representation of a guide."""
        guide = Guide.objects.create(
            section='reporting',
            title='Reporting Guide',
            content='How to report incidents',
        )
        
        self.assertIn('Reporting Incidents', str(guide))
        self.assertIn('Reporting Guide', str(guide))


class GuideAPITest(APITestCase):
    """Tests for the Guide API endpoints."""

    def setUp(self):
        """Set up test data."""
        self.guide1 = Guide.objects.create(
            section='how_it_works',
            title='How SafeZone Works',
            content='SafeZone is a community safety platform',
            icon='info',
            order=1,
            is_active=True,
        )
        self.guide2 = Guide.objects.create(
            section='reporting',
            title='Reporting Incidents',
            content='Learn how to report incidents',
            icon='report',
            order=1,
            is_active=True,
        )
        self.inactive_guide = Guide.objects.create(
            section='privacy',
            title='Privacy Guide',
            content='Privacy information',
            icon='lock',
            order=1,
            is_active=False,
        )

    @override_settings(DEBUG=True, AUTH0_DOMAIN='')
    def test_guide_list_unauthenticated_in_development(self):
        """Test that unauthenticated users can access guide list in development mode."""
        response = self.client.get('/api/guides/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('count', response.data)
        self.assertIn('results', response.data)
        self.assertEqual(response.data['count'], 2)  # Only active guides

    @override_settings(DEBUG=True, AUTH0_DOMAIN='')
    def test_guide_list_filters_inactive(self):
        """Test that inactive guides are not returned."""
        response = self.client.get('/api/guides/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        guide_ids = [guide['id'] for guide in response.data['results']]
        self.assertIn(self.guide1.id, guide_ids)
        self.assertIn(self.guide2.id, guide_ids)
        self.assertNotIn(self.inactive_guide.id, guide_ids)

    @override_settings(DEBUG=True, AUTH0_DOMAIN='')
    def test_guide_retrieve_unauthenticated_in_development(self):
        """Test that unauthenticated users can retrieve a specific guide in development mode."""
        response = self.client.get(f'/api/guides/{self.guide1.id}/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['id'], self.guide1.id)
        self.assertEqual(response.data['title'], 'How SafeZone Works')
        self.assertEqual(response.data['section'], 'how_it_works')

    @override_settings(DEBUG=True, AUTH0_DOMAIN='')
    def test_guide_retrieve_nonexistent(self):
        """Test retrieving a non-existent guide returns 404."""
        response = self.client.get('/api/guides/9999/')
        
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
