from rest_framework import serializers
from .models import EmergencyContact


class EmergencyContactSerializer(serializers.ModelSerializer):
    """Serializer for EmergencyContact model."""
    
    class Meta:
        model = EmergencyContact
        fields = [
            'id',
            'device_id',
            'name',
            'phone_number',
            'email',
            'relationship',
            'priority',
            'is_active',
            'created_at',
            'updated_at',
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def validate_phone_number(self, value):
        """Validate phone number format."""
        # Remove any spaces, dashes, or parentheses
        cleaned = value.replace(' ', '').replace('-', '').replace('(', '').replace(')', '')
        
        # Check if it contains only digits and optional + at the start
        if not cleaned.replace('+', '').isdigit():
            raise serializers.ValidationError(
                'Phone number must contain only digits, spaces, dashes, and optional +'
            )
        
        # Check minimum length (at least 7 digits for local numbers)
        digits_only = cleaned.replace('+', '')
        if len(digits_only) < 7:
            raise serializers.ValidationError(
                'Phone number must be at least 7 digits long'
            )
        
        return value
    
    def validate_email(self, value):
        """Validate email format if provided."""
        if value:
            from django.core.validators import EmailValidator
            from django.core.exceptions import ValidationError as DjangoValidationError
            
            validator = EmailValidator()
            try:
                validator(value)
            except DjangoValidationError:
                raise serializers.ValidationError(
                    'Please enter a valid email address'
                )
        return value
    
    def validate_priority(self, value):
        """Validate priority is positive."""
        if value < 1:
            raise serializers.ValidationError(
                'Priority must be at least 1'
            )
        if value > 100:
            raise serializers.ValidationError(
                'Priority must be at most 100'
            )
        return value
