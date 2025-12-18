import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/profile/cubit/safe_zone_cubit.dart';
import 'package:safe_zone/profile/models/safe_zone_model.dart';

class SafeZoneFormScreen extends StatefulWidget {
  const SafeZoneFormScreen({this.safeZone, super.key});

  final SafeZone? safeZone;

  @override
  State<SafeZoneFormScreen> createState() => _SafeZoneFormScreenState();
}

class _SafeZoneFormScreenState extends State<SafeZoneFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  late SafeZoneType _selectedType;
  late double _radius;
  late bool _notifyOnEnter;
  late bool _notifyOnExit;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.safeZone?.name ?? '');
    _latitudeController = TextEditingController(
      text: widget.safeZone?.location.latitude.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.safeZone?.location.longitude.toString() ?? '',
    );
    _selectedType = widget.safeZone?.type ?? SafeZoneType.home;
    _radius = widget.safeZone?.radius ?? 500;
    _notifyOnEnter = widget.safeZone?.notifyOnEnter ?? true;
    _notifyOnExit = widget.safeZone?.notifyOnExit ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions denied')),
            );
          }
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _latitudeController.text = position.latitude.toString();
        _longitudeController.text = position.longitude.toString();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final latitude = double.tryParse(_latitudeController.text);
      final longitude = double.tryParse(_longitudeController.text);

      if (latitude == null || longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid coordinates')),
        );
        return;
      }

      final safeZone = SafeZone(
        id: widget.safeZone?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        location: LatLng(latitude, longitude),
        radius: _radius,
        type: _selectedType,
        notifyOnEnter: _notifyOnEnter,
        notifyOnExit: _notifyOnExit,
      );

      if (widget.safeZone == null) {
        context.read<SafeZoneCubit>().addSafeZone(safeZone);
      } else {
        context.read<SafeZoneCubit>().updateSafeZone(safeZone);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Text(
          widget.safeZone == null ? 'Add Safe Zone' : 'Edit Safe Zone',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'e.g., Home, Office, School',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(LineIcons.tag),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Type selector
            Text(
              'Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: SafeZoneType.values.map((type) {
                return ChoiceChip(
                  label: Text(type.displayName),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedType = type;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Location section
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: _isLoadingLocation ? null : _useCurrentLocation,
                  icon: _isLoadingLocation
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LineIcons.mapMarker, size: 18),
                  label: const Text('Use Current'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    decoration: InputDecoration(
                      labelText: 'Latitude',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final lat = double.tryParse(value);
                      if (lat == null || lat < -90 || lat > 90) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    decoration: InputDecoration(
                      labelText: 'Longitude',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final lon = double.tryParse(value);
                      if (lon == null || lon < -180 || lon > 180) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Radius slider
            Text(
              'Radius: ${(_radius / 1000).toStringAsFixed(1)} km',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: theme.colorScheme.primary,
                thumbColor: theme.colorScheme.primary,
                trackHeight: 4,
              ),
              child: Slider(
                value: _radius,
                min: 100,
                max: 5000,
                divisions: 49,
                label: '${(_radius / 1000).toStringAsFixed(1)} km',
                onChanged: (value) {
                  setState(() {
                    _radius = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Notification settings
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Notify on Enter'),
              subtitle: const Text('Get notified when entering this zone'),
              value: _notifyOnEnter,
              onChanged: (value) {
                setState(() {
                  _notifyOnEnter = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Notify on Exit'),
              subtitle: const Text('Get notified when leaving this zone'),
              value: _notifyOnExit,
              onChanged: (value) {
                setState(() {
                  _notifyOnExit = value;
                });
              },
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.safeZone == null ? 'Add Safe Zone' : 'Save Changes',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
