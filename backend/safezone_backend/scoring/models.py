from django.db import models
from django.utils import timezone
from encrypted_model_fields.fields import EncryptedCharField
from incident_reporting.models import Incident
from datetime import timedelta
import hashlib


def hash_device_id(device_id):
    """Create a consistent hash of device_id for lookups."""
    return hashlib.sha256(device_id.encode()).hexdigest()


class UserProfile(models.Model):
    """Model to track user scores, tiers, and achievements."""
    
    # Use encrypted device_id as unique identifier for privacy
    device_id = EncryptedCharField(max_length=255)
    device_id_hash = models.CharField(max_length=64, unique=True, db_index=True)
    
    # Scoring fields
    total_points = models.IntegerField(default=0)
    reports_count = models.IntegerField(default=0)
    confirmations_count = models.IntegerField(default=0)
    
    # Tier information (calculated from total_points)
    current_tier = models.IntegerField(default=1)
    
    # Accuracy tracking
    verified_reports = models.IntegerField(default=0)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        ordering = ['-total_points']
        indexes = [
            models.Index(fields=['-total_points']),
            models.Index(fields=['current_tier']),
        ]
    
    def __str__(self):
        return f"Profile (hash: {self.device_id_hash[:8]}...) - Tier {self.current_tier} - {self.total_points} pts"
    
    def save(self, *args, **kwargs):
        """Generate device_id_hash on save."""
        if self.device_id and not self.device_id_hash:
            self.device_id_hash = hash_device_id(str(self.device_id))
        super().save(*args, **kwargs)
    
    @property
    def tier_name(self):
        """Get the tier name based on points."""
        return self.get_tier_name(self.total_points)
    
    @property
    def tier_icon(self):
        """Get the tier icon based on points."""
        return self.get_tier_icon(self.total_points)
    
    @property
    def accuracy_percentage(self):
        """Calculate accuracy percentage."""
        if self.reports_count == 0:
            return 0
        return round((self.verified_reports / self.reports_count) * 100, 1)
    
    @staticmethod
    def get_tier_from_points(points):
        """Calculate tier number from points."""
        if points >= 1200:
            return 7
        elif points >= 801:
            return 6
        elif points >= 501:
            return 5
        elif points >= 301:
            return 4
        elif points >= 151:
            return 3
        elif points >= 51:
            return 2
        else:
            return 1
    
    @staticmethod
    def get_tier_name(points):
        """Get tier name from points."""
        tier_names = {
            7: "Legendary Watchmaster",
            6: "Safety Sentinel",
            5: "Truth Blazer",
            4: "Community Guardian",
            3: "Urban Detective",
            2: "Neighborhood Watch",
            1: "Fresh Eye Scout"
        }
        tier = UserProfile.get_tier_from_points(points)
        return tier_names.get(tier, "Fresh Eye Scout")
    
    @staticmethod
    def get_tier_icon(points):
        """Get tier icon from points."""
        tier_icons = {
            7: "🌟",
            6: "👑",
            5: "🔥",
            4: "🦸",
            3: "🔍",
            2: "🛡️",
            1: "👁️"
        }
        tier = UserProfile.get_tier_from_points(points)
        return tier_icons.get(tier, "👁️")
    
    @staticmethod
    def get_tier_reward(tier):
        """Get tier reward description."""
        tier_rewards = {
            7: "Legendary frame",
            6: "Crown with sparkles",
            5: "Animated fire icon",
            4: "Gold hero badge",
            3: "Silver magnifier",
            2: "Bronze shield",
            1: "New Watcher badge"
        }
        return tier_rewards.get(tier, "New Watcher badge")
    
    def update_tier(self):
        """Update tier based on current points."""
        new_tier = self.get_tier_from_points(self.total_points)
        tier_changed = new_tier != self.current_tier
        self.current_tier = new_tier
        return tier_changed
    
    def add_report_points(self, incident):
        """Add points for creating a report."""
        base_points = 10
        time_bonus = 0
        
        # Check if report was within 1 hour
        time_diff = timezone.now() - incident.timestamp
        if time_diff <= timedelta(hours=1):
            time_bonus = 2
        
        points_earned = base_points + time_bonus
        self.total_points += points_earned
        self.reports_count += 1
        
        # Update tier
        tier_changed = self.update_tier()
        self.save()
        
        return {
            'points_earned': points_earned,
            'base_points': base_points,
            'time_bonus': time_bonus,
            'total_points': self.total_points,
            'tier_changed': tier_changed,
            'new_tier': self.current_tier if tier_changed else None
        }
    
    def add_confirmation_points(self):
        """Add points for confirming an incident."""
        points_earned = 5
        self.total_points += points_earned
        self.confirmations_count += 1
        
        # Update tier
        tier_changed = self.update_tier()
        self.save()
        
        return {
            'points_earned': points_earned,
            'total_points': self.total_points,
            'tier_changed': tier_changed,
            'new_tier': self.current_tier if tier_changed else None
        }


class IncidentConfirmation(models.Model):
    """Model to track user confirmations of incidents."""
    
    incident = models.ForeignKey(
        Incident,
        on_delete=models.CASCADE,
        related_name='confirmations'
    )
    device_id = EncryptedCharField(max_length=255)
    device_id_hash = models.CharField(max_length=64, db_index=True)
    confirmed_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-confirmed_at']
        # Prevent duplicate confirmations using hash
        unique_together = ['incident', 'device_id_hash']
        indexes = [
            models.Index(fields=['incident', '-confirmed_at']),
        ]
    
    def __str__(self):
        return f"Confirmation for Incident #{self.incident.id} at {self.confirmed_at}"
    
    def save(self, *args, **kwargs):
        """Generate device_id_hash on save."""
        if self.device_id and not self.device_id_hash:
            self.device_id_hash = hash_device_id(str(self.device_id))
        super().save(*args, **kwargs)


class Badge(models.Model):
    """Model to track special badges earned by users."""
    
    BADGE_TYPES = [
        ('first_responder', 'First Responder'),
        ('truth_triangulator', 'Truth Triangulator'),
        ('night_owl', 'Night Owl'),
        ('accuracy_ace', 'Accuracy Ace'),
    ]
    
    profile = models.ForeignKey(
        UserProfile,
        on_delete=models.CASCADE,
        related_name='badges'
    )
    badge_type = models.CharField(max_length=50, choices=BADGE_TYPES)
    earned_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ['-earned_at']
        unique_together = ['profile', 'badge_type']
        indexes = [
            models.Index(fields=['profile', 'badge_type']),
        ]
    
    def __str__(self):
        return f"{self.get_badge_type_display()} - {self.profile}"
    
    @property
    def badge_icon(self):
        """Get badge icon."""
        icons = {
            'first_responder': '🚨',
            'truth_triangulator': '🎯',
            'night_owl': '🦉',
            'accuracy_ace': '⭐',
        }
        return icons.get(self.badge_type, '✅')
    
    @property
    def badge_description(self):
        """Get badge description."""
        descriptions = {
            'first_responder': 'First to report in your zone',
            'truth_triangulator': '5+ confirmations earned',
            'night_owl': 'Active during late-night hours',
            'accuracy_ace': '95%+ verification accuracy',
        }
        return descriptions.get(self.badge_type, 'Special achievement')
