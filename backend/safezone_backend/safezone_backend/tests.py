"""
Tests for safezone_backend settings and configuration.
"""
import os
import unittest
from unittest.mock import patch


class FieldEncryptionKeyTestCase(unittest.TestCase):
    """Test cases for FIELD_ENCRYPTION_KEY validation and generation."""

    def test_valid_fernet_key_accepted(self):
        """Test that a valid Fernet key from environment is accepted."""
        from cryptography.fernet import Fernet
        
        # Generate a valid key
        valid_key = Fernet.generate_key().decode()
        
        # Mock the environment variable
        with patch.dict(os.environ, {'FIELD_ENCRYPTION_KEY': valid_key}):
            # Import settings module (this will call get_field_encryption_key)
            import importlib
            from safezone_backend import settings
            importlib.reload(settings)
            
            # Verify the key is used
            self.assertEqual(settings.FIELD_ENCRYPTION_KEY, valid_key)
            self.assertEqual(len(settings.FIELD_ENCRYPTION_KEY), 44)
    
    def test_invalid_key_raises_error(self):
        """Test that an invalid key raises a clear error."""
        # Use the old placeholder that was causing issues
        invalid_key = "your-fernet-encryption-key-here-44-characters"
        
        with patch.dict(os.environ, {'FIELD_ENCRYPTION_KEY': invalid_key}):
            # Importing should raise ValueError
            with self.assertRaises(ValueError) as context:
                import importlib
                from safezone_backend import settings
                importlib.reload(settings)
            
            # Verify error message is helpful
            self.assertIn("Invalid FIELD_ENCRYPTION_KEY", str(context.exception))
            self.assertIn("Generate a valid key", str(context.exception))
    
    def test_empty_key_uses_fallback(self):
        """Test that an empty key triggers fallback generation."""
        with patch.dict(os.environ, {'FIELD_ENCRYPTION_KEY': ''}):
            import importlib
            from safezone_backend import settings
            importlib.reload(settings)
            
            # Should generate a key from SECRET_KEY
            self.assertIsNotNone(settings.FIELD_ENCRYPTION_KEY)
            self.assertEqual(len(settings.FIELD_ENCRYPTION_KEY), 44)
    
    def test_missing_key_uses_fallback(self):
        """Test that missing key triggers fallback generation."""
        # Remove the key if it exists
        env_copy = os.environ.copy()
        env_copy.pop('FIELD_ENCRYPTION_KEY', None)
        
        with patch.dict(os.environ, env_copy, clear=True):
            import importlib
            from safezone_backend import settings
            importlib.reload(settings)
            
            # Should generate a key from SECRET_KEY
            self.assertIsNotNone(settings.FIELD_ENCRYPTION_KEY)
            self.assertEqual(len(settings.FIELD_ENCRYPTION_KEY), 44)
    
    def test_generated_key_is_valid_fernet_key(self):
        """Test that the auto-generated key is a valid Fernet key."""
        from cryptography.fernet import Fernet
        
        with patch.dict(os.environ, {}, clear=True):
            import importlib
            from safezone_backend import settings
            importlib.reload(settings)
            
            # Try to create a Fernet instance with the generated key
            # This will raise an exception if the key is invalid
            try:
                Fernet(settings.FIELD_ENCRYPTION_KEY.encode())
                key_is_valid = True
            except Exception:
                key_is_valid = False
            
            self.assertTrue(key_is_valid, "Auto-generated key should be a valid Fernet key")


if __name__ == '__main__':
    unittest.main()
