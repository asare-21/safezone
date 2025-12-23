import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/profile/profile.dart';
import 'package:safe_zone/profile/view/safe_zones_screen.dart';
import 'package:safe_zone/utils/device_id_utils.dart';
import 'package:safe_zone/utils/global.dart';

// Color constants for profile screen
const Color _lightBlueBackground = Color(0xFFEFF6FF);
const Color _avatarBackground = Color(0xFFFFE4CC);
const Color _avatarIconColor = Color(0xFF8B7355);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserScore();
  }

  Future<void> _loadUserScore() async {
    if (!mounted) return;
    
    final deviceId = await DeviceIdUtils.getDeviceId();

    if (!mounted) return;
    
    context.read<ScoringCubit>().loadUserProfile(deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

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
            _buildUserProfileCard(theme, context),
            const SizedBox(height: 24),
            _buildSectionHeader(theme, 'MAP SETTINGS'),
            _buildSettingsCard(
              theme,
              children: [
                _buildAlertRadiusItem(theme),
                const Divider(),

                // TODO(joasare019): Add mapp settings here to manage default zoom, map location icon and alert radius. Use class FunIconLoader to load custom icons. Use a cubit to manage all of this.
                _buildLocationIconItem(theme, context),
                const Divider(),
                _buildDefaultZoomItem(theme),
              ],
            ),

            const SizedBox(height: 24),

            // Alerts & Notifications Section
            _buildSectionHeader(theme, 'ALERTS & NOTIFICATIONS'),
            BlocBuilder<NotificationSettingsCubit, NotificationSettingsState>(
              builder: (context, state) {
                final cubit = context.read<NotificationSettingsCubit>();
                return _buildSettingsCard(
                  theme,
                  children: [
                    _buildToggleItem(
                      theme,
                      context,
                      icon: LineIcons.bell,
                      iconColor: Theme.of(context).colorScheme.primary,
                      iconBgColor: _lightBlueBackground,
                      title: 'Push Notifications',
                      value: state.pushNotifications,
                      onChanged: (value) =>
                          cubit.togglePushNotifications(value, value: value),
                    ),
                    const Divider(height: 1),
                    _buildToggleItem(
                      theme,
                      context,
                      icon: LineIcons.mapMarker,
                      iconColor: Theme.of(context).colorScheme.primary,
                      iconBgColor: _lightBlueBackground,
                      title: 'Proximity Alerts',
                      value: state.proximityAlerts,
                      onChanged: (value) =>
                          cubit.toggleProximityAlerts(value, value: value),
                    ),

                    const Divider(height: 1),
                    _buildToggleItem(
                      theme,
                      context,
                      icon: LineIcons.volumeUp,
                      iconColor: Theme.of(context).colorScheme.primary,
                      iconBgColor: _lightBlueBackground,
                      title: 'Sound & Vibration',
                      value: state.soundVibration,
                      onChanged: (value) =>
                          cubit.toggleSoundVibration(value, value: value),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Privacy & Safety Section
            _buildSectionHeader(theme, 'PRIVACY & SAFETY'),

            _buildSettingsCard(
              theme,
              children: [
                BlocBuilder<ProfileSettingsCubit, ProfileSettingsState>(
                  builder: (context, state) {
                    return _buildToggleItemWithSubtitle(
                      theme,
                      context,
                      icon: LineIcons.userSecret,
                      iconColor: Theme.of(context).colorScheme.primary,
                      iconBgColor: _lightBlueBackground,
                      title: 'Anonymous Reporting',
                      subtitle:
                          'Your username will be hidden on public maps. Admins can still see your ID for safety verification.',
                      value: state.anonymousReporting,
                      onChanged: (value) {
                        context
                            .read<ProfileSettingsCubit>()
                            .setAnonymousReporting(value);
                      },
                    );
                  },
                ),
                // const Divider(height: 1),
                // BlocBuilder<
                //   NotificationSettingsCubit,
                //   NotificationSettingsState
                // >(
                //   builder: (context, state) {
                //     final cubit = context.read<NotificationSettingsCubit>();
                //     return _buildToggleItem(
                //       theme,
                //       context,
                //       icon: LineIcons.share,
                //       iconColor: Theme.of(context).colorScheme.primary,
                //       iconBgColor: _lightBlueBackground,
                //       title: 'Share Location with Contacts',
                //       value: state.shareLocationWithContacts,
                //       onChanged: cubit.toggleShareLocationWithContacts,
                //     );
                //   },
                // ),
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
                  icon: LineIcons.mapMarked,
                  iconColor: Theme.of(context).colorScheme.primary,
                  iconBgColor: _lightBlueBackground,
                  title: 'Safe Zones',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const SafeZonesScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildNavigationItem(
                  theme,
                  icon: LineIcons.history,
                  iconColor: Theme.of(context).colorScheme.primary,
                  iconBgColor: _lightBlueBackground,
                  title: 'My Incident History',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const IncidentHistoryScreen(),
                      ),
                    );
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
                    //TODO (joasare019): Implement logout functioanloty. Route the user to the home screen when logout is completed.
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
                appVersion,
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

  Widget _buildUserProfileCard(ThemeData theme, BuildContext context) {
    return BlocBuilder<ScoringCubit, ScoringState>(
      builder: (context, state) {
        if (state is ScoringLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (state is ScoringError) {
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
              ),
              child: Column(
                children: [
                  const Icon(
                    LineIcons.exclamationCircle,
                    size: 48,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to load scoring data',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // Get user score from state or use default values
        final userScore = state is ScoringLoaded ? state.userScore : null;

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
                            'SafeZone User',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Truth Hunter',
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
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
                        Text(
                          '${userScore?.tierIcon ?? '👁️'} ${userScore?.tierName ?? 'Fresh Eye Scout'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${userScore?.accuracyPercentage.toStringAsFixed(0) ?? '0'}% accuracy',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _lightBlueBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Semantics(
                        label: 'User points: ${userScore?.totalPoints ?? 0} points',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LineIcons.award,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${userScore?.totalPoints ?? 0} pts',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
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
                    value: userScore?.progressToNextTier ?? 0.0,
                    minHeight: 8,
                    backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                if (userScore != null && userScore.currentTier < 7) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${userScore.pointsInCurrentTier} / ${userScore.pointsNeededInCurrentTier} pts to next tier',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ] else if (userScore != null && userScore.currentTier >= 7) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Max tier reached! 🌟',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: LineIcons.flag,
                      label: 'Reports',
                      value: (userScore?.reportsCount ?? 0).toString(),
                      theme: theme,
                    ),
                    _buildStatItem(
                      icon: LineIcons.checkCircle,
                      label: 'Confirms',
                      value: (userScore?.confirmationsCount ?? 0).toString(),
                      theme: theme,
                    ),
                    _buildStatItem(
                      icon: LineIcons.award,
                      label: 'Badges',
                      value: (userScore?.badges?.length ?? 0).toString(),
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
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
    ThemeData theme,
    BuildContext context, {
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
              activeTrackColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItemWithSubtitle(
    ThemeData theme,
    BuildContext context, {
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
              activeTrackColor: Theme.of(context).colorScheme.primary,
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
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
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
                    child: Icon(
                      LineIcons.bullseye,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
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
                    '${state.alertRadius.toStringAsFixed(1)} km',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
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
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        inactiveTrackColor: theme.dividerColor.withValues(
                          alpha: 0.2,
                        ),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                      ),
                      child: Slider(
                        value: state.alertRadius,
                        min: 0.5,
                        max: 10,
                        divisions: 19,
                        onChanged: (value) {
                          context.read<ProfileCubit>().updateAlertRadius(value);
                        },
                      ),
                    ),
                  ),
                  Text(
                    '10km',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationIconItem(ThemeData theme, BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return InkWell(
          onTap: () => _showLocationIconPicker(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _lightBlueBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LineIcons.marker,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Location Icon',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.asset(
                      state.locationIcon,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultZoomItem(ThemeData theme) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
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
                    child: Icon(
                      LineIcons.searchPlus,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Default Map Zoom',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    state.defaultZoom.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '10',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Theme.of(context).colorScheme.primary,
                        inactiveTrackColor: theme.dividerColor.withValues(
                          alpha: 0.2,
                        ),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                      ),
                      child: Slider(
                        value: state.defaultZoom,
                        min: 10,
                        max: 18,
                        divisions: 8,
                        onChanged: (value) {
                          context.read<ProfileCubit>().updateDefaultZoom(value);
                        },
                      ),
                    ),
                  ),
                  Text(
                    '18',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLocationIconPicker(BuildContext context) {
    final iconLoader = FunIconLoader();
    final icons = iconLoader.getFunIcons();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Select Location Icon'),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: icons.length,
              itemBuilder: (gridContext, index) {
                final iconPath = icons[index];
                return BlocBuilder<ProfileCubit, ProfileState>(
                  bloc: context.read<ProfileCubit>(),
                  builder: (builderContext, state) {
                    final isSelected = state.locationIcon == iconPath;
                    return GestureDetector(
                      onTap: () {
                        context.read<ProfileCubit>().updateLocationIcon(
                          iconPath,
                        );
                        Navigator.of(dialogContext).pop();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).dividerColor.withValues(alpha: 0.2),
                            width: isSelected ? 3 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.asset(
                            iconPath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
