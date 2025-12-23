from django.test import TestCase, override_settings
from django.utils import timezone
from django.db import IntegrityError
from datetime import timedelta
from rest_framework.test import APIClient, APIRequestFactory, force_authenticate
from rest_framework import status
from user_settings.models import UserDevice, SafeZone, UserPreferences
from django.contrib.auth.models import User
from incident_reporting.models import Incident
from safezone_backend.security_utils import (
    cleanup_expired_incidents,
    cleanup_inactive_user_preferences,
    export_user_data,
    delete_user_data
)
from authentication.auth0 import Auth0User
from user_settings.views import UserDeviceRegisterView


class EncryptedFieldsTestCase(TestCase):
    """Test that sensitive fields are properly encrypted."""

    def setUp(self):
        """Set up test data."""
        self.test_device_id = "test-device-12345"
        self.test_fcm_token = "fcm-token-abcdefghijklmnop"
        
    def test_user_device_encryption(self):
        """Test that UserDevice fields are encrypted in database."""
        # Create a UserDevice with sensitive data
        device = UserDevice.objects.create(
            device_id=self.test_device_id,
            fcm_token=self.test_fcm_token,
            platform='android'
        )
        
        # Verify the device can be retrieved and decrypted
        retrieved = UserDevice.objects.get(pk=device.pk)
        self.assertEqual(retrieved.device_id, self.test_device_id)
        self.assertEqual(retrieved.fcm_token, self.test_fcm_token)
        
        # Verify that data in memory matches what was stored
        device.refresh_from_db()
        self.assertEqual(device.device_id, self.test_device_id)
        self.assertEqual(device.fcm_token, self.test_fcm_token)
    
    def test_safe_zone_device_id_encryption(self):
        """Test that SafeZone device_id is encrypted."""
        zone = SafeZone.objects.create(
            device_id=self.test_device_id,
            name="Home",
            latitude=37.7749,
            longitude=-122.4194,
            radius=500,
            zone_type='home'
        )
        
        retrieved = SafeZone.objects.get(pk=zone.pk)
        self.assertEqual(retrieved.device_id, self.test_device_id)
    
    def test_user_preferences_device_id_encryption(self):
        """Test that UserPreferences device_id is encrypted."""
        prefs = UserPreferences.objects.create(
            device_id=self.test_device_id,
            alert_radius=5.0,
            push_notifications=True
        )
        
        retrieved = UserPreferences.objects.get(pk=prefs.pk)
        self.assertEqual(retrieved.device_id, self.test_device_id)
    
    def test_encrypted_field_uniqueness(self):
        """Test that uniqueness constraints work with encrypted fields."""
        # Create first device
        UserDevice.objects.create(
            device_id=self.test_device_id,
            fcm_token=self.test_fcm_token,
            platform='android'
        )
        
        # Attempting to create duplicate should raise error
        with self.assertRaises(IntegrityError):
            UserDevice.objects.create(
                device_id=self.test_device_id,
                fcm_token="different-token",
                platform='ios'
            )


class SafeZoneTestCase(TestCase):
    """Test SafeZone functionality."""
    
    def test_contains_point(self):
        """Test the contains_point method for geofencing."""
        # San Francisco center
        zone = SafeZone.objects.create(
            device_id="test-device",
            name="SF Center",
            latitude=37.7749,
            longitude=-122.4194,
            radius=1000,  # 1km radius
            zone_type='custom'
        )
        
        # Point inside the zone (very close)
        self.assertTrue(zone.contains_point(37.7749, -122.4194))
        
        # Point outside the zone (far away)
        self.assertFalse(zone.contains_point(40.7128, -74.0060))  # NYC


class DataRetentionTestCase(TestCase):
    """Test data retention and cleanup functionality."""
    
    def setUp(self):
        """Set up test data."""
        from incident_reporting.models import Incident
        
        # Create old and new incidents
        old_date = timezone.now() - timedelta(days=100)
        new_date = timezone.now() - timedelta(days=10)
        
        self.old_incident = Incident.objects.create(
            category='theft',
            latitude=37.7749,
            longitude=-122.4194,
            title='Old Incident',
            description='This is old'
        )
        self.old_incident.timestamp = old_date
        self.old_incident.save()
        
        self.new_incident = Incident.objects.create(
            category='assault',
            latitude=37.7750,
            longitude=-122.4195,
            title='New Incident',
            description='This is new'
        )
        self.new_incident.timestamp = new_date
        self.new_incident.save()
    
    def test_cleanup_expired_incidents(self):
        """Test that old incidents are cleaned up."""
        # Should delete the old incident (>90 days)
        deleted = cleanup_expired_incidents()
        self.assertEqual(deleted, 1)
        
        # Verify old incident is gone, new one remains
        self.assertFalse(Incident.objects.filter(pk=self.old_incident.pk).exists())
        self.assertTrue(Incident.objects.filter(pk=self.new_incident.pk).exists())
    
    def test_cleanup_inactive_preferences(self):
        """Test that inactive user preferences are cleaned up."""
        
        # Create old inactive preferences
        old_prefs = UserPreferences.objects.create(
            device_id="old-device",
            alert_radius=5.0
        )
        old_date = timezone.now() - timedelta(days=400)
        old_prefs.updated_at = old_date
        old_prefs.save()
        
        # Create recent preferences
        new_prefs = UserPreferences.objects.create(
            device_id="new-device",
            alert_radius=3.0
        )
        
        # Cleanup should remove old preferences
        deleted = cleanup_inactive_user_preferences()
        self.assertEqual(deleted, 1)
        
        # Verify old prefs gone, new prefs remain
        self.assertFalse(UserPreferences.objects.filter(pk=old_prefs.pk).exists())
        self.assertTrue(UserPreferences.objects.filter(pk=new_prefs.pk).exists())


class UserDataManagementTestCase(TestCase):
    """Test user data export and deletion for GDPR/CCPA compliance."""
    
    def setUp(self):
        """Set up test data."""
        self.device_id = "test-device-gdpr"
        
        # Create user data
        UserDevice.objects.create(
            device_id=self.device_id,
            fcm_token="test-token",
            platform='android'
        )
        
        UserPreferences.objects.create(
            device_id=self.device_id,
            alert_radius=5.0,
            push_notifications=True
        )
        
        SafeZone.objects.create(
            device_id=self.device_id,
            name="Home",
            latitude=37.7749,
            longitude=-122.4194,
            radius=500,
            zone_type='home'
        )
    
    def test_export_user_data(self):
        """Test exporting all user data."""
        data = export_user_data(self.device_id)
        
        # Verify all data is exported
        self.assertEqual(data['device_id'], self.device_id)
        self.assertEqual(len(data['devices']), 1)
        self.assertIn('preferences', data)
        self.assertEqual(len(data['safe_zones']), 1)
        
        # Verify exported data structure
        self.assertEqual(data['devices'][0]['platform'], 'android')
        self.assertEqual(data['preferences']['alert_radius'], 5.0)
        self.assertEqual(data['safe_zones'][0]['name'], 'Home')
    
    def test_delete_user_data(self):
        """Test deleting all user data."""
        # Delete all data for the device
        result = delete_user_data(self.device_id)
        
        # Verify deletion counts
        self.assertEqual(result['devices'], 1)
        self.assertEqual(result['preferences'], 1)
        self.assertEqual(result['safe_zones'], 1)
        
        # Verify data is actually deleted
        self.assertEqual(UserDevice.objects.filter(device_id=self.device_id).count(), 0)
        self.assertEqual(UserPreferences.objects.filter(device_id=self.device_id).count(), 0)
        self.assertEqual(SafeZone.objects.filter(device_id=self.device_id).count(), 0)


class SecuritySettingsTestCase(TestCase):
    """Test Django security settings."""
    
    def test_security_middleware_installed(self):
        """Test that security middleware is properly configured."""
        from django.conf import settings
        
        middleware = settings.MIDDLEWARE
        self.assertIn('django.middleware.security.SecurityMiddleware', middleware)
        self.assertIn('django.middleware.clickjacking.XFrameOptionsMiddleware', middleware)
    
    def test_security_headers_configured(self):
        """Test that security headers are configured."""
        from django.conf import settings
        
        # These should be True in all cases
        self.assertTrue(settings.SECURE_CONTENT_TYPE_NOSNIFF)
        self.assertTrue(settings.SECURE_BROWSER_XSS_FILTER)
        self.assertEqual(settings.X_FRAME_OPTIONS, 'DENY')
        
        # Session security
        self.assertTrue(settings.SESSION_COOKIE_HTTPONLY)
        self.assertTrue(settings.CSRF_COOKIE_HTTPONLY)
    
    def test_password_validators_configured(self):
        """Test that password validators are configured."""
        from django.conf import settings
        
        validators = settings.AUTH_PASSWORD_VALIDATORS
        self.assertGreater(len(validators), 0)
        
        # Check for specific validators
        validator_names = [v['NAME'] for v in validators]
        self.assertIn(
            'django.contrib.auth.password_validation.MinimumLengthValidator',
            validator_names
        )


class UserDeviceRegistrationTestCase(TestCase):
    """Test user device registration with Auth0 user association."""
    
    def setUp(self):
        """Set up test fixtures."""
        self.factory = APIRequestFactory()
        self.view = UserDeviceRegisterView.as_view()
        
        # Create a mock Auth0 user
        self.auth0_sub = 'auth0|123456789'
        self.auth0_email = 'test@example.com'
        
    def test_device_registration_creates_django_user(self):
        """Test that device registration creates a Django User from Auth0 info."""
        # Create a mock Auth0 user
        auth0_user = Auth0User({
            'sub': self.auth0_sub,
            'email': self.auth0_email,
        })
        
        # Prepare device registration data
        device_data = {
            'device_id': 'test-device-123',
            'fcm_token': 'test-fcm-token',
            'platform': 'android',
            'is_active': True,
        }
        
        # Create a POST request
        request = self.factory.post(
            '/api/devices/register/',
            device_data,
            format='json'
        )
        # Force authenticate with the Auth0 user
        force_authenticate(request, user=auth0_user)
        
        # Call the view
        response = self.view(request)
        
        # Verify response is successful
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Verify Django User was created
        django_user = User.objects.filter(username=self.auth0_sub).first()
        self.assertIsNotNone(django_user, "Django User should be created from Auth0 info")
        self.assertEqual(django_user.email, self.auth0_email)
        self.assertTrue(django_user.is_active)
        
        # Verify device was created and associated with user
        # Note: Due to encrypted fields, we need to iterate to find the device
        all_devices = UserDevice.objects.all()
        device = None
        for d in all_devices:
            if d.device_id == 'test-device-123':
                device = d
                break
        
        self.assertIsNotNone(device, "Device should be registered")
        self.assertIsNotNone(device.user, "Device should be associated with a user")
        self.assertEqual(device.user.username, self.auth0_sub)
        self.assertEqual(device.user.email, self.auth0_email)
    
    def test_device_update_associates_existing_user(self):
        """Test that updating a device associates it with the authenticated user."""
        # Create a device without user association
        device = UserDevice.objects.create(
            device_id='test-device-456',
            fcm_token='old-token',
            platform='ios',
        )
        self.assertIsNone(device.user, "Device should initially have no user")
        
        # Create a mock Auth0 user
        auth0_user = Auth0User({
            'sub': self.auth0_sub,
            'email': self.auth0_email,
        })
        
        # Update device with new token
        device_data = {
            'device_id': 'test-device-456',
            'fcm_token': 'new-token',
            'platform': 'ios',
            'is_active': True,
        }
        
        # Create a POST request
        request = self.factory.post(
            '/api/devices/register/',
            device_data,
            format='json'
        )
        force_authenticate(request, user=auth0_user)
        
        # Call the view
        response = self.view(request)
        
        # Verify response is successful
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify device was updated and associated with user
        device.refresh_from_db()
        self.assertEqual(device.fcm_token, 'new-token')
        self.assertIsNotNone(device.user, "Device should now be associated with a user")
        self.assertEqual(device.user.username, self.auth0_sub)
    
    def test_multiple_devices_for_same_user(self):
        """Test that a user can have multiple devices registered."""
        # Create a mock Auth0 user
        auth0_user = Auth0User({
            'sub': self.auth0_sub,
            'email': self.auth0_email,
        })
        
        # Register first device
        device1_data = {
            'device_id': 'device-1',
            'fcm_token': 'token-1',
            'platform': 'android',
            'is_active': True,
        }
        request1 = self.factory.post('/api/devices/register/', device1_data, format='json')
        force_authenticate(request1, user=auth0_user)
        response1 = self.view(request1)
        self.assertEqual(response1.status_code, status.HTTP_201_CREATED)
        
        # Register second device
        device2_data = {
            'device_id': 'device-2',
            'fcm_token': 'token-2',
            'platform': 'ios',
            'is_active': True,
        }
        request2 = self.factory.post('/api/devices/register/', device2_data, format='json')
        force_authenticate(request2, user=auth0_user)
        response2 = self.view(request2)
        self.assertEqual(response2.status_code, status.HTTP_201_CREATED)
        
        # Verify both devices are associated with the same user
        user = User.objects.get(username=self.auth0_sub)
        user_devices = UserDevice.objects.filter(user=user)
        self.assertEqual(user_devices.count(), 2)
        
        device_ids = set(d.device_id for d in user_devices)
        self.assertEqual(device_ids, {'device-1', 'device-2'})
    
    def test_user_email_update(self):
        """Test that user email is updated if it changes in Auth0."""
        # Create initial user
        User.objects.create(
            username=self.auth0_sub,
            email='old@example.com',
            is_active=True,
        )
        
        # Create Auth0 user with new email
        auth0_user = Auth0User({
            'sub': self.auth0_sub,
            'email': 'new@example.com',
        })
        
        # Register device
        device_data = {
            'device_id': 'test-device',
            'fcm_token': 'test-token',
            'platform': 'android',
            'is_active': True,
        }
        request = self.factory.post('/api/devices/register/', device_data, format='json')
        force_authenticate(request, user=auth0_user)
        response = self.view(request)
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        # Verify email was updated
        user = User.objects.get(username=self.auth0_sub)
        self.assertEqual(user.email, 'new@example.com')


