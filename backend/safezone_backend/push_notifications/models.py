from django.db import models


class NotificationLog(models.Model):
    """Model to log sent notifications for tracking and debugging."""
    
    incident = models.ForeignKey(
        'incident_reporting.Incident',
        on_delete=models.CASCADE,
        related_name='notifications',
    )
    device_id = models.CharField(max_length=255)
    fcm_token = models.TextField()
    sent_at = models.DateTimeField(auto_now_add=True)
    success = models.BooleanField(default=True)
    error_message = models.TextField(blank=True, null=True)

    class Meta:
        ordering = ['-sent_at']

    def __str__(self):
        return f"Notification for incident {self.incident_id} to {self.device_id}"

