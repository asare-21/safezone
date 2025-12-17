import 'package:bloc/bloc.dart';
import 'package:safe_zone/map/models/incident_model.dart';

part 'map_filter_state.dart';

/// Cubit that manages map filter state and calculates risk level
class MapFilterCubit extends Cubit<MapFilterState> {
  MapFilterCubit()
      : super(
          const MapFilterState(
            timeFilter: TimeFilter.twentyFourHours,
            selectedCategories: {
              IncidentCategory.theft,
              IncidentCategory.assault,
              IncidentCategory.suspicious,
              IncidentCategory.lighting,
            },
            riskLevel: RiskLevel.moderate,
          ),
        );

  List<Incident> _allIncidents = [];

  /// Initialize incidents and calculate initial risk level
  void initializeIncidents(List<Incident> incidents) {
    _allIncidents = incidents;
    _recalculateRiskLevel();
  }

  /// Update the time filter and recalculate risk level
  void updateTimeFilter(TimeFilter filter) {
    emit(state.copyWith(timeFilter: filter));
    _recalculateRiskLevel();
  }

  /// Toggle a category filter and recalculate risk level
  void toggleCategory(IncidentCategory category) {
    final newCategories = Set<IncidentCategory>.from(state.selectedCategories);
    if (newCategories.contains(category)) {
      newCategories.remove(category);
    } else {
      newCategories.add(category);
    }
    emit(state.copyWith(selectedCategories: newCategories));
    _recalculateRiskLevel();
  }

  /// Get filtered incidents based on current state
  List<Incident> getFilteredIncidents() {
    return _allIncidents.where((incident) {
      // Filter by time
      if (!incident.isWithinTimeFilter(state.timeFilter)) {
        return false;
      }
      
      // Filter by category
      if (!state.selectedCategories.contains(incident.category)) {
        return false;
      }
      
      // Filter by search query
      if (state.searchQuery.isNotEmpty) {
        final query = state.searchQuery.toLowerCase();
        final titleMatch = incident.title.toLowerCase().contains(query);
        final descriptionMatch = incident.description
            ?.toLowerCase()
            .contains(query) ?? false;
        return titleMatch || descriptionMatch;
      }
      
      return true;
    }).toList();
  }

  /// Update search query
  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _recalculateRiskLevel();
  }

  /// Clear search query
  void clearSearch() {
    emit(state.copyWith(searchQuery: ''));
    _recalculateRiskLevel();
  }

  /// Clear all filters
  void clearFilters() {
    emit(
      state.copyWith(
        selectedCategories: {
          IncidentCategory.theft,
          IncidentCategory.assault,
          IncidentCategory.suspicious,
          IncidentCategory.lighting,
        },
        searchQuery: '',
      ),
    );
    _recalculateRiskLevel();
  }

  void _recalculateRiskLevel() {
    final filteredIncidents = getFilteredIncidents();
    final riskLevel = _calculateRiskLevel(filteredIncidents);
    emit(state.copyWith(riskLevel: riskLevel));
  }

  RiskLevel _calculateRiskLevel(List<Incident> incidents) {
    if (incidents.isEmpty) {
      return RiskLevel.safe;
    }

    // Calculate risk based on number of incidents and their severity
    final highSeverityCount = incidents.where((incident) {
      return incident.category == IncidentCategory.assault ||
          incident.category == IncidentCategory.theft;
    }).length;

    final totalCount = incidents.length;

    // Risk calculation logic:
    // - High risk: 5+ incidents or 3+ high severity incidents
    // - Moderate risk: 2-4 incidents or 1-2 high severity incidents
    // - Safe: 0-1 incidents with no high severity
    if (totalCount >= 5 || highSeverityCount >= 3) {
      return RiskLevel.high;
    } else if (totalCount >= 2 || highSeverityCount >= 1) {
      return RiskLevel.moderate;
    } else {
      return RiskLevel.safe;
    }
  }
}
