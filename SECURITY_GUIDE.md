# Security Implementation Guide for Developers

## Quick Start

This guide helps developers understand and maintain the security and privacy features implemented in SafeZone.

## Environment Setup

### 1. Create .env File

Copy the example environment file and configure it:

```bash
cd backend/safezone_backend
cp .env.example .env
```

### 2. Generate Secret Keys

Generate secure secret keys for production:

```bash
# Generate Django SECRET_KEY
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Generate separate encryption key
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

Add these to your `.env` file:
```
DJANGO_SECRET_KEY=<generated-key-1>
FIELD_ENCRYPTION_KEY=<generated-key-2>
```

## Running the Application Securely

### Development Mode

```bash
# Set environment variables
export DJANGO_DEBUG=True
export DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Run development server
python manage.py runserver
```

### Production Mode

```bash
# Set environment variables
export DJANGO_DEBUG=False
export DJANGO_SECRET_KEY=<your-secret-key>
export FIELD_ENCRYPTION_KEY=<your-encryption-key>
export DJANGO_ALLOWED_HOSTS=yourdomain.com

# Install dependencies
pip install -r requirements.txt

# Collect static files
python manage.py collectstatic --noinput

# Run migrations
python manage.py migrate

# Run with gunicorn (recommended)
gunicorn safezone_backend.wsgi:application --bind 0.0.0.0:8000
```

## Data Retention & Cleanup

### Manual Cleanup

Run the cleanup command to remove expired data:

```bash
# Dry run (see what would be deleted)
python manage.py cleanup_expired_data --dry-run

# Actual cleanup
python manage.py cleanup_expired_data
```

### Automated Cleanup (Recommended)

Set up a cron job to run cleanup daily:

```bash
# Add to crontab
0 2 * * * cd /path/to/safezone_backend && /path/to/venv/bin/python manage.py cleanup_expired_data
```

Or use Celery for scheduled tasks:

```python
# In celery.py
from celery import Celery
from celery.schedules import crontab

app = Celery('safezone')

app.conf.beat_schedule = {
    'cleanup-expired-data': {
        'task': 'safezone_backend.tasks.cleanup_expired_data',
        'schedule': crontab(hour=2, minute=0),  # Run at 2 AM daily
    },
}
```

## User Data Management (GDPR/CCPA)

### Export User Data

```python
from safezone_backend.security_utils import export_user_data

# Export all data for a device
data = export_user_data(device_id='user-device-123')
# Returns JSON with all user data
```

### Delete User Data

```python
from safezone_backend.security_utils import delete_user_data

# Delete all data for a device
result = delete_user_data(device_id='user-device-123')
# Returns summary of deleted items
```

## Testing

### Run All Tests

```bash
# Run all tests
python manage.py test

# Run specific test module
python manage.py test user_settings.tests

# Run with coverage
coverage run --source='.' manage.py test
coverage report
coverage html  # Generate HTML report
```

### Test Encrypted Fields

```bash
# Run encryption tests specifically
python manage.py test user_settings.tests.EncryptedFieldsTestCase
```

### Test Security Settings

```bash
python manage.py test user_settings.tests.SecuritySettingsTestCase
```

## Security Checklist

### Before Deploying to Production

- [ ] Change `SECRET_KEY` from default value
- [ ] Generate separate `FIELD_ENCRYPTION_KEY`
- [ ] Set `DEBUG = False`
- [ ] Configure `ALLOWED_HOSTS` with actual domain
- [ ] Enable HTTPS/SSL on web server
- [ ] Verify `SECURE_SSL_REDIRECT = True`
- [ ] Set up HSTS headers
- [ ] Configure CORS for specific origins only
- [ ] Set up automated data cleanup cron job
- [ ] Enable database backups with encryption
- [ ] Configure secure session settings
- [ ] Set up monitoring and logging
- [ ] Review and test all security headers
- [ ] Perform security audit/penetration test

### Regular Maintenance

- [ ] Update Django and dependencies monthly
- [ ] Check for security advisories weekly
- [ ] Review access logs monthly
- [ ] Test backup restoration quarterly
- [ ] Rotate encryption keys annually
- [ ] Review and update privacy policy as needed
- [ ] Audit user data retention compliance quarterly

## Common Issues

### Issue: "ModuleNotFoundError: No module named 'encrypted_model_fields'"

**Solution**: Install required dependencies
```bash
pip install -r requirements.txt
```

### Issue: Encrypted fields not working

**Solution**: Ensure `FIELD_ENCRYPTION_KEY` is set
```bash
export FIELD_ENCRYPTION_KEY=<your-key>
# or add to .env file
```

### Issue: Migration errors with encrypted fields

**Solution**: Make migrations after installing encrypted_model_fields
```bash
pip install django-encrypted-model-fields
python manage.py makemigrations
python manage.py migrate
```

## API Security

### Authentication

Currently using AllowAny for development. For production:

```python
# settings.py
REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework.authentication.TokenAuthentication',
    ],
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/day',
        'user': '1000/day',
    },
}
```

### Rate Limiting

Configure rate limits based on your needs:

```python
# settings.py
REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/day',      # Anonymous users
        'user': '1000/day',     # Authenticated users
        'burst': '60/min',      # Burst protection
    },
}
```

## Monitoring & Logging

### Security Event Logging

```python
# Log important security events
import logging
security_logger = logging.getLogger('security')

# Example usage
security_logger.warning(f'Failed login attempt for device: {device_id}')
security_logger.info(f'User data exported for device: {device_id}')
security_logger.critical(f'Potential security breach detected')
```

### Configure Logging

```python
# settings.py
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'security_file': {
            'level': 'WARNING',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/var/log/safezone/security.log',
            'maxBytes': 1024 * 1024 * 10,  # 10MB
            'backupCount': 5,
        },
    },
    'loggers': {
        'security': {
            'handlers': ['security_file'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}
```

## Additional Resources

- [Django Security Documentation](https://docs.djangoproject.com/en/4.2/topics/security/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [GDPR Compliance Guide](https://gdpr.eu/)
- [CCPA Compliance Guide](https://oag.ca.gov/privacy/ccpa)
- [SafeZone Privacy Policy](../PRIVACY_POLICY.md)
- [SafeZone Data Encryption](../DATA_ENCRYPTION.md)

## Support

For security issues or questions:
- Open a GitHub issue (for non-sensitive issues)
- Use GitHub Security Advisories (for vulnerabilities)
- Review documentation in `PRIVACY_POLICY.md` and `DATA_ENCRYPTION.md`
