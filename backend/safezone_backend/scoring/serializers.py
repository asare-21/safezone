from rest_framework import serializers
from .models import UserProfile, Badge, IncidentConfirmation


class BadgeSerializer(serializers.ModelSerializer):
    """Serializer for Badge model."""
    
    badge_icon = serializers.CharField(read_only=True)
    badge_description = serializers.CharField(read_only=True)
    badge_display_name = serializers.CharField(source='get_badge_type_display', read_only=True)
    
    class Meta:
        model = Badge
        fields = [
            'id',
            'badge_type',
            'badge_display_name',
            'badge_icon',
            'badge_description',
            'earned_at',
        ]
        read_only_fields = ['id', 'earned_at']


class UserProfileSerializer(serializers.ModelSerializer):
    """Serializer for UserProfile model."""
    
    tier_name = serializers.CharField(read_only=True)
    tier_icon = serializers.CharField(read_only=True)
    accuracy_percentage = serializers.FloatField(read_only=True)
    tier_reward = serializers.SerializerMethodField()
    badges = BadgeSerializer(many=True, read_only=True)
    
    class Meta:
        model = UserProfile
        fields = [
            'id',
            'device_id',
            'total_points',
            'reports_count',
            'confirmations_count',
            'current_tier',
            'tier_name',
            'tier_icon',
            'tier_reward',
            'verified_reports',
            'accuracy_percentage',
            'badges',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id',
            'total_points',
            'reports_count',
            'confirmations_count',
            'current_tier',
            'verified_reports',
            'created_at',
            'updated_at',
        ]
    
    def get_tier_reward(self, obj):
        """Get tier reward description."""
        return UserProfile.get_tier_reward(obj.current_tier)


class UserProfileSummarySerializer(serializers.ModelSerializer):
    """Lightweight serializer for UserProfile for leaderboards."""
    
    tier_name = serializers.CharField(read_only=True)
    tier_icon = serializers.CharField(read_only=True)
    accuracy_percentage = serializers.FloatField(read_only=True)
    
    class Meta:
        model = UserProfile
        fields = [
            'id',
            'total_points',
            'reports_count',
            'confirmations_count',
            'current_tier',
            'tier_name',
            'tier_icon',
            'accuracy_percentage',
        ]
        read_only_fields = fields


class IncidentConfirmationSerializer(serializers.ModelSerializer):
    """Serializer for IncidentConfirmation model."""
    
    class Meta:
        model = IncidentConfirmation
        fields = [
            'id',
            'incident',
            'device_id',
            'confirmed_at',
        ]
        read_only_fields = ['id', 'confirmed_at']


class ConfirmIncidentRequestSerializer(serializers.Serializer):
    """Serializer for confirming an incident."""
    
    device_id = serializers.CharField(max_length=255, required=True)


class ScoringResponseSerializer(serializers.Serializer):
    """Serializer for scoring response after actions."""
    
    points_earned = serializers.IntegerField()
    total_points = serializers.IntegerField()
    tier_changed = serializers.BooleanField()
    new_tier = serializers.IntegerField(allow_null=True)
    tier_name = serializers.CharField(allow_null=True)
    tier_icon = serializers.CharField(allow_null=True)
    message = serializers.CharField()
