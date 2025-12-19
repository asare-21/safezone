import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/profile/cubit/safe_zone_cubit.dart';
import 'package:safe_zone/profile/cubit/safe_zone_state.dart';
import 'package:safe_zone/profile/models/safe_zone_model.dart';
import 'package:safe_zone/profile/view/safe_zone_form_screen.dart';

class SafeZonesScreen extends StatelessWidget {
  const SafeZonesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SafeZoneCubit(),
      child: const _SafeZonesView(),
    );
  }
}

const Color _lightBlueBackground = Color(0xFFEFF6FF);

class _SafeZonesView extends StatelessWidget {
  const _SafeZonesView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: const Text(
          'Safe Zones',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<SafeZoneCubit, SafeZoneState>(
        builder: (context, state) {
          if (state.status == SafeZoneStatus.loading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state.status == SafeZoneStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LineIcons.exclamationTriangle,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? 'An error occurred',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state.safeZones.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LineIcons.mapMarked,
                    size: 80,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Safe Zones Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Create safe zones like home, work, or school to get notifications when entering or leaving',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),

                child: Card(
                  elevation: 0.1,
                  color: _lightBlueBackground,
                  child: ListTile(
                    title: Text(
                      'Maximum Number of Safe Zones',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'You are alowed a maximum of 5 safe zones',
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.safeZones.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final zone = state.safeZones[index];
                    return _SafeZoneCard(zone: zone);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => BlocProvider.value(
                value: context.read<SafeZoneCubit>(),
                child: const SafeZoneFormScreen(),
              ),
            ),
          );
        },
        icon: const Icon(LineIcons.plus),
        label: const Text('Add Safe Zone'),
      ),
    );
  }
}

class _SafeZoneCard extends StatelessWidget {
  const _SafeZoneCard({required this.zone});

  final SafeZone zone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: zone.isActive
                        ? const Color(0xFFEFF6FF)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForType(zone.type),
                    color: zone.isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zone.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${zone.type.displayName} • ${(zone.radius / 1000).toStringAsFixed(1)} km radius',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: zone.isActive,
                  onChanged: (value) {
                    context.read<SafeZoneCubit>().toggleSafeZone(zone.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  theme,
                  icon: LineIcons.arrowCircleRight,
                  label: 'Enter',
                  enabled: zone.notifyOnEnter,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  theme,
                  icon: LineIcons.arrowCircleLeft,
                  label: 'Exit',
                  enabled: zone.notifyOnExit,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => BlocProvider.value(
                          value: context.read<SafeZoneCubit>(),
                          child: SafeZoneFormScreen(safeZone: zone),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(LineIcons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () {
                    _showDeleteConfirmation(context, zone);
                  },
                  icon: Icon(
                    LineIcons.trash,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required bool enabled,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: enabled
            ? const Color(0xFFEFF6FF)
            : theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: enabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(SafeZoneType type) {
    switch (type) {
      case SafeZoneType.home:
        return LineIcons.home;
      case SafeZoneType.work:
        return LineIcons.briefcase;
      case SafeZoneType.school:
        return LineIcons.graduationCap;
      case SafeZoneType.custom:
        return LineIcons.mapMarker;
    }
  }

  void _showDeleteConfirmation(BuildContext context, SafeZone zone) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Safe Zone'),
          content: Text('Are you sure you want to delete "${zone.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<SafeZoneCubit>().deleteSafeZone(zone.id);
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
