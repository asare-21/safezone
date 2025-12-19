"""
Django management command to clean up expired data according to retention policies.

Usage:
    python manage.py cleanup_expired_data [--dry-run]
"""

from django.core.management.base import BaseCommand
from safezone_backend.security_utils import (
    cleanup_expired_incidents,
    cleanup_inactive_user_preferences,
    cleanup_inactive_device_tokens,
)


class Command(BaseCommand):
    help = 'Clean up expired data according to retention policies'

    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Show what would be deleted without actually deleting',
        )

    def handle(self, *args, **options):
        dry_run = options.get('dry_run', False)
        
        if dry_run:
            self.stdout.write(self.style.WARNING('DRY RUN MODE - No data will be deleted'))
        
        self.stdout.write('Starting data cleanup...\n')
        
        # Clean up expired incidents
        self.stdout.write('Checking for expired incidents...')
        if not dry_run:
            incidents_deleted = cleanup_expired_incidents()
            self.stdout.write(
                self.style.SUCCESS(f'✓ Deleted {incidents_deleted} expired incident(s)')
            )
        else:
            # In dry-run, just count
            from incident_reporting.models import Incident
            from datetime import timedelta
            from django.utils import timezone
            from django.conf import settings
            
            retention_days = getattr(settings, 'INCIDENT_RETENTION_DAYS', 90)
            cutoff_date = timezone.now() - timedelta(days=retention_days)
            count = Incident.objects.filter(timestamp__lt=cutoff_date).count()
            self.stdout.write(
                self.style.WARNING(f'Would delete {count} expired incident(s)')
            )
        
        # Clean up inactive user preferences
        self.stdout.write('\nChecking for inactive user preferences...')
        if not dry_run:
            prefs_deleted = cleanup_inactive_user_preferences()
            self.stdout.write(
                self.style.SUCCESS(f'✓ Deleted {prefs_deleted} inactive preference(s)')
            )
        else:
            from user_settings.models import UserPreferences
            from datetime import timedelta
            from django.utils import timezone
            from django.conf import settings
            
            inactive_days = getattr(settings, 'USER_PREFERENCES_INACTIVE_DAYS', 365)
            cutoff_date = timezone.now() - timedelta(days=inactive_days)
            count = UserPreferences.objects.filter(updated_at__lt=cutoff_date).count()
            self.stdout.write(
                self.style.WARNING(f'Would delete {count} inactive preference(s)')
            )
        
        # Clean up inactive device tokens
        self.stdout.write('\nChecking for inactive device tokens...')
        if not dry_run:
            devices_deleted = cleanup_inactive_device_tokens()
            self.stdout.write(
                self.style.SUCCESS(f'✓ Deleted {devices_deleted} inactive device token(s)')
            )
        else:
            from user_settings.models import UserDevice
            from datetime import timedelta
            from django.utils import timezone
            from django.conf import settings
            
            inactive_days = getattr(settings, 'DEVICE_TOKEN_INACTIVE_DAYS', 180)
            cutoff_date = timezone.now() - timedelta(days=inactive_days)
            count = UserDevice.objects.filter(
                updated_at__lt=cutoff_date,
                is_active=False
            ).count()
            self.stdout.write(
                self.style.WARNING(f'Would delete {count} inactive device token(s)')
            )
        
        self.stdout.write('\n' + '='*50)
        if dry_run:
            self.stdout.write(self.style.WARNING('DRY RUN COMPLETE - No changes made'))
        else:
            self.stdout.write(self.style.SUCCESS('Data cleanup complete!'))
        self.stdout.write('='*50)
