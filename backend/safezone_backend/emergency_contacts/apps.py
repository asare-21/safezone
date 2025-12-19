from django.apps import AppConfig


class EmergencyContactsConfig(AppConfig):
    """App configuration for emergency_contacts."""
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'emergency_contacts'
    verbose_name = 'Emergency Contacts'
