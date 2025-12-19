from django.db import models


class Incident(models.Model):
    """Model for incident reports."""

    CATEGORY_CHOICES = [
        ('accident', 'Accident'),
        ('fire', 'Fire'),
        ('theft', 'Theft'),
        ('suspicious', 'Suspicious Activity'),
        ('lighting', 'Lighting Issue'),
        ('assault', 'Assault'),
        ('vandalism', 'Vandalism'),
        ('harassment', 'Harassment'),
        ('roadHazard', 'Road Hazard'),
        ('animalDanger', 'Animal Danger'),
        ('medicalEmergency', 'Medical Emergency'),
        ('naturalDisaster', 'Natural Disaster'),
        ('powerOutage', 'Power Outage'),
        ('waterIssue', 'Water Issue'),
        ('noise', 'Noise Complaint'),
        ('trespassing', 'Trespassing'),
        ('drugActivity', 'Drug Activity'),
        ('weaponSighting', 'Weapon Sighting'),
    ]

    id = models.AutoField(primary_key=True)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    latitude = models.FloatField()
    longitude = models.FloatField()
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True, null=True)
    timestamp = models.DateTimeField(auto_now_add=True)
    confirmed_by = models.IntegerField(default=1)
    notify_nearby = models.BooleanField(default=False)

    class Meta:
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['-timestamp']),
            models.Index(fields=['category']),
        ]

    def __str__(self):
        return f"{self.category} - {self.title}"
