part of 'map_filter_cubit.dart';

/// State for map filters and risk level
class MapFilterState {
  const MapFilterState({
    required this.timeFilter,
    required this.selectedCategories,
    required this.riskLevel,
    this.searchQuery = '',
  });

  final TimeFilter timeFilter;
  final Set<IncidentCategory> selectedCategories;
  final RiskLevel riskLevel;
  final String searchQuery;

  MapFilterState copyWith({
    TimeFilter? timeFilter,
    Set<IncidentCategory>? selectedCategories,
    RiskLevel? riskLevel,
    String? searchQuery,
  }) {
    return MapFilterState(
      timeFilter: timeFilter ?? this.timeFilter,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      riskLevel: riskLevel ?? this.riskLevel,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapFilterState &&
        other.timeFilter == timeFilter &&
        _setEquals(other.selectedCategories, selectedCategories) &&
        other.riskLevel == riskLevel &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode => Object.hash(
        timeFilter,
        selectedCategories,
        riskLevel,
        searchQuery,
      );

  /// Helper method to compare sets for equality
  bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.every(b.contains);
  }
}
