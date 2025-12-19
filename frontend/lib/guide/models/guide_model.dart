import 'package:equatable/equatable.dart';

/// Represents a guide section category
enum GuideSection {
  howItWorks('how_it_works'),
  reporting('reporting'),
  alerts('alerts'),
  trustScore('trust_score'),
  privacy('privacy'),
  bestPractices('best_practices'),
  emergency('emergency'),
  gettingStarted('getting_started');

  const GuideSection(this.value);
  final String value;

  static GuideSection fromString(String value) {
    return GuideSection.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GuideSection.howItWorks,
    );
  }
}

/// Model representing a safety guide article
class Guide extends Equatable {
  const Guide({
    required this.id,
    required this.section,
    required this.title,
    required this.content,
    required this.order, required this.isActive, required this.createdAt, required this.updatedAt, this.icon,
  });

  /// Create a Guide from JSON data
  factory Guide.fromJson(Map<String, dynamic> json) {
    return Guide(
      id: json['id'] as int,
      section: GuideSection.fromString(json['section'] as String),
      title: json['title'] as String,
      content: json['content'] as String,
      icon: json['icon'] as String?,
      order: json['order'] as int,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  final int id;
  final GuideSection section;
  final String title;
  final String content;
  final String? icon;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Convert Guide to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section.value,
      'title': title,
      'content': content,
      'icon': icon,
      'order': order,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        section,
        title,
        content,
        icon,
        order,
        isActive,
        createdAt,
        updatedAt,
      ];
}
