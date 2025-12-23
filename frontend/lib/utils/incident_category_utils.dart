import 'package:safe_zone/map/models/incident_model.dart';

/// Utility functions for incident categories
class IncidentCategoryUtils {
  /// Convert string category name to display name
  static String getDisplayName(String category) {
    // Try to match with enum
    try {
      final enumValue = IncidentCategory.values.firstWhere(
        (e) => e.name == category,
      );
      return enumValue.displayName;
    } catch (e) {
      // Fallback to formatted string if no match
      return _formatCategoryString(category);
    }
  }

  /// Format category string to readable format
  static String _formatCategoryString(String category) {
    // Handle empty or invalid categories
    if (category.isEmpty) {
      return 'Unknown';
    }
    
    switch (category) {
      case 'accident':
        return 'Accident';
      case 'fire':
        return 'Fire';
      case 'theft':
        return 'Theft';
      case 'suspicious':
        return 'Suspicious Activity';
      case 'lighting':
        return 'Lighting Issue';
      case 'assault':
        return 'Assault';
      case 'vandalism':
        return 'Vandalism';
      case 'harassment':
        return 'Harassment';
      case 'roadHazard':
        return 'Road Hazard';
      case 'animalDanger':
        return 'Animal Danger';
      case 'medicalEmergency':
        return 'Medical Emergency';
      case 'naturalDisaster':
        return 'Natural Disaster';
      case 'powerOutage':
        return 'Power Outage';
      case 'waterIssue':
        return 'Water Issue';
      case 'noise':
        return 'Noise Complaint';
      case 'trespassing':
        return 'Trespassing';
      case 'drugActivity':
        return 'Drug Activity';
      case 'weaponSighting':
        return 'Weapon Sighting';
      default:
        // If no match, capitalize first letter
        return category.substring(0, 1).toUpperCase() + category.substring(1);
    }
  }
}
