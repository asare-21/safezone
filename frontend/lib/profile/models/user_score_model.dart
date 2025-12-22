/// Model for user scoring and tier information
class UserScore {
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
          ? (json['badges'] as List).map((e) => Badge.fromJson(e)).toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

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

  /// Get progress to next tier (0-1)
  double get progressToNextTier {
    if (currentTier >= 7) return 1.0; // Max tier

    final currentThreshold = _getCurrentTierThreshold();
    final nextThreshold = nextTierThreshold;
    final pointsInCurrentTier = totalPoints - currentThreshold;
    final pointsNeededForNextTier = nextThreshold - currentThreshold;

    return (pointsInCurrentTier / pointsNeededForNextTier).clamp(0.0, 1.0);
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

  const ConfirmationResponse({
    required this.pointsEarned,
    required this.totalPoints,
    required this.tierChanged,
    this.newTier,
    this.tierName,
    this.tierIcon,
    required this.message,
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
