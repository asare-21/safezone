import 'package:latlong2/latlong.dart';

/// Represents a user's location on the map
class UserLocation {
  UserLocation({
    required this.userId,
    required this.location,
    required this.iconPath,
    this.displayName,
  });

  final String userId;
  final LatLng location;
  final String iconPath;
  final String? displayName;
}
