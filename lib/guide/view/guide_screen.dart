import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'Safety Guide',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    _buildWelcomeCard(theme),
                    const SizedBox(height: 24),

                    // How SafeZone Works
                    _buildSectionTitle(theme, 'How SafeZone Works'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      icon: LineIcons.alternateShield,
                      iconColor: const Color(0xFF34C759),
                      iconBgColor: const Color(0xFFE8F5E9),
                      title: 'Crowdsourced Safety',
                      description:
                          'SafeZone uses community-reported incidents to create a real-time safety network. Users can report incidents like theft, harassment, or suspicious activity to alert others in the area.',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      icon: LineIcons.mapMarker,
                      iconColor: const Color(0xFF007AFF),
                      iconBgColor: const Color(0xFFEFF6FF),
                      title: 'Proximity Alerts',
                      description:
                          'Get notified automatically when you approach areas with recent safety incidents. Alerts are triggered based on your location and configurable alert radius.',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      icon: LineIcons.map,
                      iconColor: const Color(0xFF5856D6),
                      iconBgColor: const Color(0xFFF0F0FF),
                      title: 'Interactive Safety Map',
                      description:
                          'View real-time incidents on an interactive map with color-coded risk levels. Green areas are safe, yellow indicates moderate risk, and red shows high-risk zones.',
                    ),

                    const SizedBox(height: 32),

                    // Reporting Incidents
                    _buildSectionTitle(theme, 'Reporting Incidents'),
                    const SizedBox(height: 12),
                    _buildStepCard(
                      theme,
                      stepNumber: '1',
                      title: 'Tap the Report Button',
                      description:
                          'On the map screen, tap the prominent report button to begin.',
                    ),
                    const SizedBox(height: 12),
                    _buildStepCard(
                      theme,
                      stepNumber: '2',
                      title: 'Select Incident Type',
                      description:
                          'Choose from categories: Theft, Harassment, Assault, Suspicious Activity, or Unsafe Environment.',
                    ),
                    const SizedBox(height: 12),
                    _buildStepCard(
                      theme,
                      stepNumber: '3',
                      title: 'Add Details (Optional)',
                      description:
                          'Provide additional context to help others. Your location and timestamp are captured automatically.',
                    ),
                    const SizedBox(height: 12),
                    _buildStepCard(
                      theme,
                      stepNumber: '4',
                      title: 'Submit Report',
                      description:
                          'Submit your report. You can choose to report anonymously in your privacy settings.',
                    ),

                    const SizedBox(height: 32),

                    // Understanding Alerts
                    _buildSectionTitle(theme, 'Understanding Alerts'),
                    const SizedBox(height: 12),
                    _buildAlertTypeCard(
                      theme,
                      severity: 'High',
                      severityColor: const Color(0xFFFF4C4C),
                      description:
                          'Multiple recent incidents or high-risk areas. Exercise extreme caution and consider alternative routes.',
                    ),
                    const SizedBox(height: 12),
                    _buildAlertTypeCard(
                      theme,
                      severity: 'Medium',
                      severityColor: const Color(0xFFFF9500),
                      description:
                          'Recent incidents reported in the area. Stay alert and aware of your surroundings.',
                    ),
                    const SizedBox(height: 12),
                    _buildAlertTypeCard(
                      theme,
                      severity: 'Low',
                      severityColor: const Color(0xFF5856D6),
                      description:
                          'Minor incidents or general awareness alerts. Normal caution is advised.',
                    ),
                    const SizedBox(height: 12),
                    _buildAlertTypeCard(
                      theme,
                      severity: 'Info',
                      severityColor: const Color(0xFF8E8E93),
                      description:
                          'General information about events, traffic, or resolved incidents.',
                    ),

                    const SizedBox(height: 32),

                    // Trust Score System
                    _buildSectionTitle(theme, 'Trust Score System'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      icon: LineIcons.award,
                      iconColor: const Color(0xFFFFD700),
                      iconBgColor: const Color(0xFFFFFDF0),
                      title: 'Building Your Reputation',
                      description:
                          'Your trust score increases when you:\n• Make verified incident reports\n• Confirm existing reports ("Still an issue?")\n• Maintain accurate reporting patterns\n\nHigher trust scores give your reports more weight in the community.',
                    ),
                    const SizedBox(height: 12),
                    _buildTrustLevelCard(
                      theme,
                      level: 'Guardian',
                      range: '450-600 points',
                      description: 'High reputation contributor',
                      color: const Color(0xFF34C759),
                    ),
                    const SizedBox(height: 12),
                    _buildTrustLevelCard(
                      theme,
                      level: 'Protector',
                      range: '250-449 points',
                      description: 'Trusted community member',
                      color: const Color(0xFF007AFF),
                    ),
                    const SizedBox(height: 12),
                    _buildTrustLevelCard(
                      theme,
                      level: 'Watcher',
                      range: '100-249 points',
                      description: 'Active participant',
                      color: const Color(0xFF5856D6),
                    ),
                    const SizedBox(height: 12),
                    _buildTrustLevelCard(
                      theme,
                      level: 'Newcomer',
                      range: '0-99 points',
                      description: 'New member',
                      color: const Color(0xFF8E8E93),
                    ),

                    const SizedBox(height: 32),

                    // Privacy & Data Protection
                    _buildSectionTitle(theme, 'Privacy & Data Protection'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      icon: LineIcons.lock,
                      iconColor: const Color(0xFF34C759),
                      iconBgColor: const Color(0xFFE8F5E9),
                      title: 'Your Data is Protected',
                      description:
                          'SafeZone is committed to your privacy:\n\n• No personally identifiable information required\n• Anonymous reporting available\n• Location data used only for incidents and alerts\n• Data encrypted in transit and at rest\n• Not affiliated with law enforcement agencies',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      icon: LineIcons.userSecret,
                      iconColor: const Color(0xFF007AFF),
                      iconBgColor: const Color(0xFFEFF6FF),
                      title: 'Anonymous Reporting',
                      description:
                          'Enable anonymous reporting in Settings to hide your username on public maps. Admins can still verify your ID for safety and to prevent abuse.',
                    ),

                    const SizedBox(height: 32),

                    // Best Practices
                    _buildSectionTitle(theme, 'Safety Best Practices'),
                    const SizedBox(height: 12),
                    _buildPracticeCard(
                      theme,
                      icon: LineIcons.eye,
                      title: 'Stay Aware',
                      description:
                          'Keep your eyes on your surroundings, not just your phone.',
                    ),
                    const SizedBox(height: 12),
                    _buildPracticeCard(
                      theme,
                      icon: LineIcons.users,
                      title: 'Trust Your Instincts',
                      description:
                          'If something feels unsafe, report it and find an alternative route.',
                    ),
                    const SizedBox(height: 12),
                    _buildPracticeCard(
                      theme,
                      icon: LineIcons.share,
                      title: 'Share Your Location',
                      description:
                          'Let trusted contacts know where you are when traveling alone.',
                    ),
                    const SizedBox(height: 12),
                    _buildPracticeCard(
                      theme,
                      icon: LineIcons.checkCircle,
                      title: 'Verify Before Acting',
                      description:
                          'Use multiple sources of information. SafeZone is one tool in your safety toolkit.',
                    ),
                    const SizedBox(height: 12),
                    _buildPracticeCard(
                      theme,
                      icon: LineIcons.lightbulb,
                      title: 'Report Responsibly',
                      description:
                          'Only report genuine safety concerns to maintain community trust.',
                    ),

                    const SizedBox(height: 32),

                    // Emergency Features
                    _buildSectionTitle(theme, 'Emergency Features'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      icon: LineIcons.phoneVolume,
                      iconColor: const Color(0xFFFF4C4C),
                      iconBgColor: const Color(0xFFFFF0F0),
                      title: 'Quick Emergency Dial',
                      description:
                          'In a genuine emergency, always call local emergency services (911, 999, 112, etc.) immediately. SafeZone complements but does not replace emergency services.',
                    ),

                    const SizedBox(height: 32),

                    // Getting Started
                    _buildSectionTitle(theme, 'Getting Started'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      theme,
                      icon: LineIcons.cog,
                      iconColor: const Color(0xFF5856D6),
                      iconBgColor: const Color(0xFFF0F0FF),
                      title: 'Configure Your Settings',
                      description:
                          'Visit Settings to:\n• Set your alert radius (0.5km - 10km)\n• Enable/disable notifications\n• Configure privacy preferences\n• Manage your profile',
                    ),

                    const SizedBox(height: 32),

                    // Support section
                    _buildSupportCard(theme),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LineIcons.bookOpen,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Welcome to SafeZone',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Your comprehensive guide to staying safe with community-powered alerts and real-time incident reporting.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
    ThemeData theme, {
    required String stepNumber,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTypeCard(
    ThemeData theme, {
    required String severity,
    required Color severityColor,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: severityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$severity Severity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: severityColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustLevelCard(
    ThemeData theme, {
    required String level,
    required String range,
    required String description,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              LineIcons.award,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              range,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LineIcons.questionCircle,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Need Help?',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'SafeZone is a community-driven safety platform designed to help you stay informed and make safer decisions.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  LineIcons.exclamationTriangle,
                  color: Color(0xFFFF9500),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Remember: SafeZone complements but does not replace professional emergency services.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: const Color(0xFF8B6914),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
