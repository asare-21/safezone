class EmergencyContact {
  EmergencyContact({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.relationship,
    required this.priority,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as int,
      deviceId: json['device_id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      relationship: json['relationship'] as String,
      priority: json['priority'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final int id;
  final String deviceId;
  final String name;
  final String phoneNumber;
  final String? email;
  final String relationship;
  final int priority;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'name': name,
      'phone_number': phoneNumber,
      if (email != null) 'email': email,
      'relationship': relationship,
      'priority': priority,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  EmergencyContact copyWith({
    int? id,
    String? deviceId,
    String? name,
    String? phoneNumber,
    String? email,
    String? relationship,
    int? priority,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ContactRelationship {
  family,
  friend,
  colleague,
  neighbor,
  other;

  String get displayName {
    switch (this) {
      case ContactRelationship.family:
        return 'Family';
      case ContactRelationship.friend:
        return 'Friend';
      case ContactRelationship.colleague:
        return 'Colleague';
      case ContactRelationship.neighbor:
        return 'Neighbor';
      case ContactRelationship.other:
        return 'Other';
    }
  }
}
