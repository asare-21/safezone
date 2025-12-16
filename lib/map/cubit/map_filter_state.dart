part of 'map_filter_cubit.dart';

/// State for map filters and risk level
class MapFilterState {
  const MapFilterState({
    required this.timeFilter,
    required this.selectedCategories,
    required this.riskLevel,
  });

  final TimeFilter timeFilter;
  final Set<IncidentCategory> selectedCategories;
  final RiskLevel riskLevel;

  MapFilterState copyWith({
    TimeFilter? timeFilter,
    Set<IncidentCategory>? selectedCategories,
    RiskLevel? riskLevel,
  }) {
    return MapFilterState(
      timeFilter: timeFilter ?? this.timeFilter,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      riskLevel: riskLevel ?? this.riskLevel,
    );
  }
}
