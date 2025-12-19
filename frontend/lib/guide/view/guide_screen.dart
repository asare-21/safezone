import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/guide/guide.dart';

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
                  const Spacer(),
                  IconButton(
                    icon: const Icon(LineIcons.syncIcon),
                    onPressed: () {
                      context.read<GuideCubit>().refreshGuides();
                    },
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: BlocBuilder<GuideCubit, GuideState>(
                builder: (context, state) {
                  if (state is GuideLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is GuideError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LineIcons.exclamationTriangle,
                            size: 64,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<GuideCubit>().loadGuides();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is GuideLoaded) {
                    return _buildGuideContent(context, theme, state);
                  }

                  // Initial state
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideContent(
    BuildContext context,
    ThemeData theme,
    GuideLoaded state,
  ) {
    return RefreshIndicator(
      onRefresh: () => context.read<GuideCubit>().refreshGuides(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildWelcomeCard(theme),
            const SizedBox(height: 24),

            // Build sections dynamically from backend data
            ...GuideSection.values.map((section) {
              final sectionGuides = state.guidesBySection[section];
              if (sectionGuides == null || sectionGuides.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(theme, _getSectionTitle(section)),
                  const SizedBox(height: 12),
                  ...sectionGuides.map((guide) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildGuideCard(theme, guide),
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              );
            }),

            // Support section
            _buildSupportCard(theme),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  String _getSectionTitle(GuideSection section) {
    switch (section) {
      case GuideSection.howItWorks:
        return 'How SafeZone Works';
      case GuideSection.reporting:
        return 'Reporting Incidents';
      case GuideSection.alerts:
        return 'Understanding Alerts';
      case GuideSection.trustScore:
        return 'Trust Score System';
      case GuideSection.privacy:
        return 'Privacy & Data Protection';
      case GuideSection.bestPractices:
        return 'Safety Best Practices';
      case GuideSection.emergency:
        return 'Emergency Features';
      case GuideSection.gettingStarted:
        return 'Getting Started';
    }
  }

  IconData _getIconForGuide(String? iconName) {
    if (iconName == null) return LineIcons.infoCircle;

    switch (iconName) {
      case 'shield':
        return LineIcons.alternateShield;
      case 'map_marker':
        return LineIcons.mapMarker;
      case 'map':
        return LineIcons.map;
      case 'award':
        return LineIcons.award;
      case 'lock':
        return LineIcons.lock;
      case 'user_secret':
        return LineIcons.userSecret;
      case 'eye':
        return LineIcons.eye;
      case 'users':
        return LineIcons.users;
      case 'share':
        return LineIcons.share;
      case 'check_circle':
        return LineIcons.checkCircle;
      case 'lightbulb':
        return LineIcons.lightbulb;
      case 'phone_volume':
        return LineIcons.phoneVolume;
      case 'cog':
        return LineIcons.cog;
      default:
        return LineIcons.infoCircle;
    }
  }

  Color _getColorForSection(GuideSection section) {
    switch (section) {
      case GuideSection.howItWorks:
        return const Color(0xFF34C759);
      case GuideSection.reporting:
        return const Color(0xFF007AFF);
      case GuideSection.alerts:
        return const Color(0xFFFF9500);
      case GuideSection.trustScore:
        return const Color(0xFFFFD700);
      case GuideSection.privacy:
        return const Color(0xFF34C759);
      case GuideSection.bestPractices:
        return const Color(0xFF5856D6);
      case GuideSection.emergency:
        return const Color(0xFFFF4C4C);
      case GuideSection.gettingStarted:
        return const Color(0xFF5856D6);
    }
  }

  Widget _buildGuideCard(ThemeData theme, Guide guide) {
    final iconColor = _getColorForSection(guide.section);
    final iconBgColor = iconColor.withValues(alpha: 0.1);

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
              _getIconForGuide(guide.icon),
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
                  guide.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  guide.content,
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
