/// Model for user scoring and tier information
class UserScore {

  const UserScore({
    required this.id,
    required this.totalPoints,
    required this.reportsCount,
    required this.confirmationsCount,
    required this.currentTier,
    required this.tierName,
    required this.tierIcon,
    required this.tierReward,
    required this.verifiedReports,
    required this.accuracyPercentage,
    this.badges,
    this.createdAt,
    this.updatedAt,
  });

  /// Create UserScore from JSON
  factory UserScore.fromJson(Map<String, dynamic> json) {
    return UserScore(
      id: json['id'] as int,
      totalPoints: json['total_points'] as int,
      reportsCount: json['reports_count'] as int,
      confirmationsCount: json['confirmations_count'] as int,
      currentTier: json['current_tier'] as int,
      tierName: json['tier_name'] as String,
      tierIcon: json['tier_icon'] as String,
      tierReward: json['tier_reward'] as String,
      verifiedReports: json['verified_reports'] as int,
      accuracyPercentage: (json['accuracy_percentage'] as num).toDouble(),
      badges: json['badges'] != null
          ? (json['badges'] as List)
                .map((e) => Badge.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  /// Unique identifier
  final int id;

  /// Total points earned
  final int totalPoints;

  /// Number of reports submitted
  final int reportsCount;

  /// Number of confirmations made
  final int confirmationsCount;

  /// Current tier level (1-7)
  final int currentTier;

  /// Tier name (e.g., "Fresh Eye Scout", "Legendary Watchmaster")
  final String tierName;

  /// Tier icon emoji
  final String tierIcon;

  /// Tier reward description
  final String tierReward;

  /// Number of verified reports
  final int verifiedReports;

  /// Accuracy percentage
  final double accuracyPercentage;

  /// List of earned badges
  final List<Badge>? badges;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Convert UserScore to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'total_points': totalPoints,
      'reports_count': reportsCount,
      'confirmations_count': confirmationsCount,
      'current_tier': currentTier,
      'tier_name': tierName,
      'tier_icon': tierIcon,
      'tier_reward': tierReward,
      'verified_reports': verifiedReports,
      'accuracy_percentage': accuracyPercentage,
      'badges': badges?.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get next tier threshold
  int get nextTierThreshold {
    switch (currentTier) {
      case 1:
        return 51;
      case 2:
        return 151;
      case 3:
        return 301;
      case 4:
        return 501;
      case 5:
        return 801;
      case 6:
        return 1200;
      default:
        return 1200; // Max tier
    }
  }

  /// Get progress to next tier (0.0-1.0)
  /// 
  /// Returns a value between 0.0 and 1.0 representing progress toward the next tier.
  /// - 0.0 means just entered current tier
  /// - 1.0 means ready to advance to next tier (or at max tier)
  /// 
  /// For tier 7 (max tier), always returns 1.0.
  double get progressToNextTier {
    // Max tier reached - no next tier
    if (currentTier >= 7) return 1.0;

    final currentThreshold = _getCurrentTierThreshold();
    final nextThreshold = nextTierThreshold;
    final pointsInCurrentTier = totalPoints - currentThreshold;
    final pointsNeededForNextTier = nextThreshold - currentThreshold;

    // Safety check: avoid division by zero (should never happen with valid tiers)
    if (pointsNeededForNextTier <= 0) return 1.0;

    return (pointsInCurrentTier / pointsNeededForNextTier).clamp(0.0, 1.0);
  }

  /// Get points needed to reach the next tier
  int get pointsToNextTier {
    if (currentTier >= 7) return 0; // Max tier reached
    
    final nextThreshold = nextTierThreshold;
    final pointsNeeded = nextThreshold - totalPoints;
    return pointsNeeded > 0 ? pointsNeeded : 0;
  }

  /// Get points earned in current tier
  int get pointsInCurrentTier {
    final currentThreshold = _getCurrentTierThreshold();
    return (totalPoints - currentThreshold).clamp(0, totalPoints);
  }

  /// Get total points needed in current tier to advance
  int get pointsNeededInCurrentTier {
    if (currentTier >= 7) return 0; // Max tier
    
    final currentThreshold = _getCurrentTierThreshold();
    final nextThreshold = nextTierThreshold;
    return nextThreshold - currentThreshold;
  }

  int _getCurrentTierThreshold() {
    switch (currentTier) {
      case 1:
        return 0;
      case 2:
        return 51;
      case 3:
        return 151;
      case 4:
        return 301;
      case 5:
        return 501;
      case 6:
        return 801;
      case 7:
        return 1200;
      default:
        return 0;
    }
  }

  /// Copy with new values
  UserScore copyWith({
    int? id,
    int? totalPoints,
    int? reportsCount,
    int? confirmationsCount,
    int? currentTier,
    String? tierName,
    String? tierIcon,
    String? tierReward,
    int? verifiedReports,
    double? accuracyPercentage,
    List<Badge>? badges,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserScore(
      id: id ?? this.id,
      totalPoints: totalPoints ?? this.totalPoints,
      reportsCount: reportsCount ?? this.reportsCount,
      confirmationsCount: confirmationsCount ?? this.confirmationsCount,
      currentTier: currentTier ?? this.currentTier,
      tierName: tierName ?? this.tierName,
      tierIcon: tierIcon ?? this.tierIcon,
      tierReward: tierReward ?? this.tierReward,
      verifiedReports: verifiedReports ?? this.verifiedReports,
      accuracyPercentage: accuracyPercentage ?? this.accuracyPercentage,
      badges: badges ?? this.badges,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Model for user badges
class Badge {

  const Badge({
    required this.id,
    required this.badgeType,
    required this.badgeDisplayName,
    required this.badgeIcon,
    required this.badgeDescription,
    required this.earnedAt,
  });

  /// Create Badge from JSON
  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] as int,
      badgeType: json['badge_type'] as String,
      badgeDisplayName: json['badge_display_name'] as String,
      badgeIcon: json['badge_icon'] as String,
      badgeDescription: json['badge_description'] as String,
      earnedAt: DateTime.parse(json['earned_at'] as String),
    );
  }
  /// Badge ID
  final int id;

  /// Badge type (e.g., 'first_responder', 'truth_triangulator')
  final String badgeType;

  /// Badge display name
  final String badgeDisplayName;

  /// Badge icon
  final String badgeIcon;

  /// Badge description
  final String badgeDescription;

  /// When the badge was earned
  final DateTime earnedAt;

  /// Convert Badge to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'badge_type': badgeType,
      'badge_display_name': badgeDisplayName,
      'badge_icon': badgeIcon,
      'badge_description': badgeDescription,
      'earned_at': earnedAt.toIso8601String(),
    };
  }
}

/// Response model for confirmation actions
class ConfirmationResponse {

  const ConfirmationResponse({
    required this.pointsEarned,
    required this.totalPoints,
    required this.tierChanged,
    required this.message, this.newTier,
    this.tierName,
    this.tierIcon,
    this.confirmationCount,
  });

  /// Create ConfirmationResponse from JSON
  factory ConfirmationResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmationResponse(
      pointsEarned: json['points_earned'] as int,
      totalPoints: json['total_points'] as int,
      tierChanged: json['tier_changed'] as bool,
      newTier: json['new_tier'] as int?,
      tierName: json['tier_name'] as String?,
      tierIcon: json['tier_icon'] as String?,
      message: json['message'] as String,
      confirmationCount: json['confirmation_count'] as int?,
    );
  }
  /// Points earned from confirmation
  final int pointsEarned;

  /// Total points after confirmation
  final int totalPoints;

  /// Whether tier changed
  final bool tierChanged;

  /// New tier number if changed
  final int? newTier;

  /// New tier name if changed
  final String? tierName;

  /// New tier icon if changed
  final String? tierIcon;

  /// Success message
  final String message;

  /// Number of confirmations for this incident
  final int? confirmationCount;

  /// Convert ConfirmationResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'points_earned': pointsEarned,
      'total_points': totalPoints,
      'tier_changed': tierChanged,
      'new_tier': newTier,
      'tier_name': tierName,
      'tier_icon': tierIcon,
      'message': message,
      'confirmation_count': confirmationCount,
    };
  }
}

/// Model for nearby incidents that can be confirmed
class NearbyIncident {

  const NearbyIncident({
    required this.id,
    required this.category,
    required this.title,
    required this.latitude, required this.longitude, required this.timestamp, required this.confirmedBy, required this.distanceMeters, this.description,
  });

  /// Create NearbyIncident from JSON
  factory NearbyIncident.fromJson(Map<String, dynamic> json) {
    return NearbyIncident(
      id: json['id'] as int,
      category: json['category'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      confirmedBy: json['confirmed_by'] as int,
      distanceMeters: (json['distance_meters'] as num).toDouble(),
    );
  }
  /// Incident ID
  final int id;

  /// Incident category
  final String category;

  /// Incident title
  final String title;

  /// Incident description
  final String? description;

  /// Latitude
  final double latitude;

  /// Longitude
  final double longitude;

  /// Timestamp when incident was reported
  final DateTime timestamp;

  /// Number of confirmations
  final int confirmedBy;

  /// Distance from user in meters
  final double distanceMeters;

  /// Convert NearbyIncident to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'confirmed_by': confirmedBy,
      'distance_meters': distanceMeters,
    };
  }
}
