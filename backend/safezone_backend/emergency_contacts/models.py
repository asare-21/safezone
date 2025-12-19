from django.db import models
from django.contrib.auth.models import User
from encrypted_model_fields.fields import EncryptedCharField


class EmergencyContact(models.Model):
    """Model to store user's emergency contacts."""
    
    RELATIONSHIP_CHOICES = [
        ('family', 'Family'),
        ('friend', 'Friend'),
        ('colleague', 'Colleague'),
        ('neighbor', 'Neighbor'),
        ('other', 'Other'),
    ]
    
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='emergency_contacts',
        null=True,
        blank=True,
    )
    # Encrypted device_id for anonymous users
    device_id = EncryptedCharField(max_length=255)
    
    # Contact Information (encrypted for privacy)
    name = EncryptedCharField(max_length=200)
    phone_number = EncryptedCharField(max_length=20)
    email = EncryptedCharField(max_length=255, blank=True, null=True)
    
    relationship = models.CharField(
        max_length=20,
        choices=RELATIONSHIP_CHOICES,
        default='other',
    )
    
    # Priority order (1 is highest priority)
    priority = models.IntegerField(default=1)
    
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['priority', '-created_at']
        indexes = [
            models.Index(fields=['is_active']),
            models.Index(fields=['priority']),
        ]
    
    def __str__(self):
        return f"{self.name} ({self.relationship})"
