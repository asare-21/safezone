from django.db import models


class Guide(models.Model):
    """Model for safety guide articles and content."""

    SECTION_CHOICES = [
        ('how_it_works', 'How SafeZone Works'),
        ('reporting', 'Reporting Incidents'),
        ('alerts', 'Understanding Alerts'),
        ('trust_score', 'Trust Score System'),
        ('privacy', 'Privacy & Data Protection'),
        ('best_practices', 'Safety Best Practices'),
        ('emergency', 'Emergency Features'),
        ('getting_started', 'Getting Started'),
    ]

    id = models.AutoField(primary_key=True)
    section = models.CharField(max_length=50, choices=SECTION_CHOICES)
    title = models.CharField(max_length=200)
    content = models.TextField()
    icon = models.CharField(max_length=100, blank=True, null=True)
    order = models.IntegerField(default=0)
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['section', 'order']
        indexes = [
            models.Index(fields=['section', 'order']),
            models.Index(fields=['is_active']),
        ]

    def __str__(self):
        return f"{self.get_section_display()} - {self.title}"
