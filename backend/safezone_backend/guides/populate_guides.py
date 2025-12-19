"""
Script to populate the guides database with initial content.
Run with: python manage.py shell < guides/populate_guides.py
"""

from guides.models import Guide

# Clear existing guides
Guide.objects.all().delete()

guides_data = [
    # How SafeZone Works
    {
        'section': 'how_it_works',
        'title': 'Crowdsourced Safety',
        'content': 'SafeZone uses community-reported incidents to create a real-time safety network. Users can report incidents like theft, harassment, or suspicious activity to alert others in the area.',
        'icon': 'shield',
        'order': 1,
    },
    {
        'section': 'how_it_works',
        'title': 'Proximity Alerts',
        'content': 'Get notified automatically when you approach areas with recent safety incidents. Alerts are triggered based on your location and configurable alert radius.',
        'icon': 'map_marker',
        'order': 2,
    },
    {
        'section': 'how_it_works',
        'title': 'Interactive Safety Map',
        'content': 'View real-time incidents on an interactive map with color-coded risk levels. Green areas are safe, yellow indicates moderate risk, and red shows high-risk zones.',
        'icon': 'map',
        'order': 3,
    },
    
    # Reporting Incidents
    {
        'section': 'reporting',
        'title': 'Tap the Report Button',
        'content': 'On the map screen, tap the prominent report button to begin.',
        'icon': 'report',
        'order': 1,
    },
    {
        'section': 'reporting',
        'title': 'Select Incident Type',
        'content': 'Choose from categories: Theft, Harassment, Assault, Suspicious Activity, or Unsafe Environment.',
        'icon': 'category',
        'order': 2,
    },
    {
        'section': 'reporting',
        'title': 'Add Details (Optional)',
        'content': 'Provide additional context to help others. Your location and timestamp are captured automatically.',
        'icon': 'edit',
        'order': 3,
    },
    {
        'section': 'reporting',
        'title': 'Submit Report',
        'content': 'Submit your report. You can choose to report anonymously in your privacy settings.',
        'icon': 'send',
        'order': 4,
    },
    
    # Understanding Alerts
    {
        'section': 'alerts',
        'title': 'High Severity',
        'content': 'Multiple recent incidents or high-risk areas. Exercise extreme caution and consider alternative routes.',
        'icon': 'alert_high',
        'order': 1,
    },
    {
        'section': 'alerts',
        'title': 'Medium Severity',
        'content': 'Recent incidents reported in the area. Stay alert and aware of your surroundings.',
        'icon': 'alert_medium',
        'order': 2,
    },
    {
        'section': 'alerts',
        'title': 'Low Severity',
        'content': 'Minor incidents or general awareness alerts. Normal caution is advised.',
        'icon': 'alert_low',
        'order': 3,
    },
    {
        'section': 'alerts',
        'title': 'Info Severity',
        'content': 'General information about events, traffic, or resolved incidents.',
        'icon': 'info',
        'order': 4,
    },
    
    # Trust Score System
    {
        'section': 'trust_score',
        'title': 'Building Your Reputation',
        'content': 'Your trust score increases when you:\n• Make verified incident reports\n• Confirm existing reports ("Still an issue?")\n• Maintain accurate reporting patterns\n\nHigher trust scores give your reports more weight in the community.',
        'icon': 'award',
        'order': 1,
    },
    {
        'section': 'trust_score',
        'title': 'Guardian (450-600 points)',
        'content': 'High reputation contributor',
        'icon': 'guardian',
        'order': 2,
    },
    {
        'section': 'trust_score',
        'title': 'Protector (250-449 points)',
        'content': 'Trusted community member',
        'icon': 'protector',
        'order': 3,
    },
    {
        'section': 'trust_score',
        'title': 'Watcher (100-249 points)',
        'content': 'Active participant',
        'icon': 'watcher',
        'order': 4,
    },
    {
        'section': 'trust_score',
        'title': 'Newcomer (0-99 points)',
        'content': 'New member',
        'icon': 'newcomer',
        'order': 5,
    },
    
    # Privacy & Data Protection
    {
        'section': 'privacy',
        'title': 'Your Data is Protected',
        'content': 'SafeZone is committed to your privacy:\n\n• No personally identifiable information required\n• Anonymous reporting available\n• Location data used only for incidents and alerts\n• Data encrypted in transit (HTTPS/TLS) and at rest (AES-256)\n• Sensitive fields (device IDs, FCM tokens) encrypted in database\n• Not affiliated with law enforcement agencies\n• GDPR and CCPA compliant privacy practices',
        'icon': 'lock',
        'order': 1,
    },
    {
        'section': 'privacy',
        'title': 'Anonymous Reporting',
        'content': 'Enable anonymous reporting in Settings to hide your username on public maps. Your device ID is encrypted and stored securely. Admins can still verify report authenticity to prevent abuse while protecting your privacy.',
        'icon': 'user_secret',
        'order': 2,
    },
    {
        'section': 'privacy',
        'title': 'Data Encryption',
        'content': 'All data transmission uses HTTPS with TLS 1.2+ encryption. Sensitive database fields including device identifiers and notification tokens are encrypted using AES-256 encryption. Your data is protected both in transit and at rest.',
        'icon': 'shield_check',
        'order': 3,
    },
    {
        'section': 'privacy',
        'title': 'Data Retention',
        'content': 'Incident reports are retained for 90 days, after which they are anonymized for trend analysis. Inactive user preferences are deleted after 12 months. You can request immediate deletion of your data at any time.',
        'icon': 'clock',
        'order': 4,
    },
    {
        'section': 'privacy',
        'title': 'Your Rights (GDPR/CCPA)',
        'content': 'You have the right to:\n• Access your data\n• Correct inaccurate data\n• Request data deletion\n• Export your data\n• Opt-out of data processing\n\nContact us via GitHub to exercise these rights.',
        'icon': 'user_shield',
        'order': 5,
    },
    
    # Safety Best Practices
    {
        'section': 'best_practices',
        'title': 'Stay Aware',
        'content': 'Keep your eyes on your surroundings, not just your phone.',
        'icon': 'eye',
        'order': 1,
    },
    {
        'section': 'best_practices',
        'title': 'Trust Your Instincts',
        'content': 'If something feels unsafe, report it and find an alternative route.',
        'icon': 'users',
        'order': 2,
    },
    {
        'section': 'best_practices',
        'title': 'Share Your Location',
        'content': 'Let trusted contacts know where you are when traveling alone.',
        'icon': 'share',
        'order': 3,
    },
    {
        'section': 'best_practices',
        'title': 'Verify Before Acting',
        'content': 'Use multiple sources of information. SafeZone is one tool in your safety toolkit.',
        'icon': 'check_circle',
        'order': 4,
    },
    {
        'section': 'best_practices',
        'title': 'Report Responsibly',
        'content': 'Only report genuine safety concerns to maintain community trust.',
        'icon': 'lightbulb',
        'order': 5,
    },
    
    # Emergency Features
    {
        'section': 'emergency',
        'title': 'Quick Emergency Dial',
        'content': 'In a genuine emergency, always call local emergency services (911, 999, 112, etc.) immediately. SafeZone complements but does not replace emergency services.',
        'icon': 'phone_volume',
        'order': 1,
    },
    
    # Getting Started
    {
        'section': 'getting_started',
        'title': 'Configure Your Settings',
        'content': 'Visit Settings to:\n• Set your alert radius (0.5km - 10km)\n• Enable/disable notifications\n• Configure privacy preferences\n• Manage your profile',
        'icon': 'cog',
        'order': 1,
    },
]

# Create all guides
for guide_data in guides_data:
    Guide.objects.create(**guide_data)

print(f"Successfully created {len(guides_data)} guide entries!")
