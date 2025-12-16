import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

// Color constants for profile screen
const Color _primaryBlue = Color(0xFF3B82F6);
const Color _lightBlueBackground = Color(0xFFEFF6FF);
const Color _avatarBackground = Color(0xFFFFE4CC);
const Color _avatarIconColor = Color(0xFF8B7355);

// Trust score constants
const int _currentTrustScore = 450;
const int _maxTrustScore = 600;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;
  bool _proximityAlerts = true;
  bool _soundVibration = false;
  bool _anonymousReporting = true;
  bool _shareLocationWithContacts = false;
  double _alertRadius = 2.5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings & Privacy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // User Profile Card
            _buildUserProfileCard(theme),
            const SizedBox(height: 24),

            // Alerts & Notifications Section
            _buildSectionHeader(theme, 'ALERTS & NOTIFICATIONS'),
            _buildSettingsCard(
              theme,
              children: [
                _buildToggleItem(
                  theme,
                  icon: LineIcons.bell,
                  iconColor: _primaryBlue,
                  iconBgColor: _lightBlueBackground,
                  title: 'Push Notifications',
                  value: _pushNotifications,
                  onChanged: (value) {
                    setState(() {
                      _pushNotifications = value;
                    });
                  },
                ),
                const Divider(height: 1),
                _buildToggleItem(
                  theme,
                  icon: LineIcons.mapMarker,
                  iconColor: _primaryBlue,
                  iconBgColor: _lightBlueBackground,
                  title: 'Proximity Alerts',
                  value: _proximityAlerts,
                  onChanged: (value) {
                    setState(() {
                      _proximityAlerts = value;
                    });
                  },
                ),
                const Divider(height: 1),
                _buildAlertRadiusItem(theme),
                const Divider(height: 1),
                _buildToggleItem(
                  theme,
                  icon: LineIcons.volumeUp,
                  iconColor: _primaryBlue,
                  iconBgColor: _lightBlueBackground,
                  title: 'Sound & Vibration',
                  value: _soundVibration,
                  onChanged: (value) {
                    setState(() {
                      _soundVibration = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Privacy & Safety Section
            _buildSectionHeader(theme, 'PRIVACY & SAFETY'),
            _buildSettingsCard(
              theme,
              children: [
                _buildToggleItemWithSubtitle(
                  theme,
                  icon: LineIcons.userSecret,
                  iconColor: _primaryBlue,
                  iconBgColor: _lightBlueBackground,
                  title: 'Anonymous Reporting',
                  subtitle:
                      'Your username will be hidden on public maps. Admins can still see your ID for safety verification.',
                  value: _anonymousReporting,
                  onChanged: (value) {
                    setState(() {
                      _anonymousReporting = value;
                    });
                  },
                ),
                const Divider(height: 1),
                _buildToggleItem(
                  theme,
                  icon: LineIcons.shareAlt,
                  iconColor: _primaryBlue,
                  iconBgColor: _lightBlueBackground,
                  title: 'Share Location with Contacts',
                  value: _shareLocationWithContacts,
                  onChanged: (value) {
                    setState(() {
                      _shareLocationWithContacts = value;
                    });
                  },
                ),
                const Divider(height: 1),
                _buildNavigationItem(
                  theme,
                  icon: LineIcons.ban,
                  iconColor: _primaryBlue,
                  iconBgColor: _lightBlueBackground,
                  title: 'Manage Blocked Users',
                  onTap: () {
                    // Navigate to blocked users screen
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Account Section
            _buildSectionHeader(theme, 'ACCOUNT'),
            _buildSettingsCard(
              theme,
              children: [
                _buildNavigationItem(
                  theme,
                  icon: LineIcons.history,
                  iconColor: _primaryBlue,
                  iconBgColor: _lightBlueBackground,
                  title: 'My Incident History',
                  onTap: () {
                    // Navigate to incident history screen
                  },
                ),
                const Divider(height: 1),
                _buildNavigationItem(
                  theme,
                  icon: LineIcons.key,
                  iconColor: _primaryBlue,
                  iconBgColor: _lightBlueBackground,
                  title: 'Change Password',
                  onTap: () {
                    // Navigate to change password screen
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Log Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: TextButton(
                  onPressed: () {
                    // Handle log out
                  },
                  child: Text(
                    'Log Out',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Version Info
            Center(
              child: Text(
                'SafeZone v2.4.1 (Build 2045)',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileCard(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Profile Avatar
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _avatarBackground,
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    LineIcons.user,
                    size: 32,
                    color: _avatarIconColor,
                  ),
                ),
                const SizedBox(width: 16),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sarah Jenkins',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Member since 2021',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Trust Score
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trust Score: Guardian',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'High reputation contributor',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _lightBlueBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '$_currentTrustScore/$_maxTrustScore',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _currentTrustScore / _maxTrustScore,
                minHeight: 8,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  _primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme, {required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildToggleItem(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: _primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItemWithSubtitle(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: _primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertRadiusItem(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _lightBlueBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LineIcons.bullseye,
                  size: 20,
                  color: _primaryBlue,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Alert Radius',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${_alertRadius.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '500m',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _primaryBlue,
                    inactiveTrackColor:
                        theme.dividerColor.withValues(alpha: 0.2),
                    thumbColor: _primaryBlue,
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _alertRadius,
                    min: 0.5,
                    max: 10.0,
                    divisions: 19,
                    onChanged: (value) {
                      setState(() {
                        _alertRadius = value;
                      });
                    },
                  ),
                ),
              ),
              Text(
                '10km',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
