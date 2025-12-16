import 'package:bloc/bloc.dart';
import 'package:safe_zone/map/models/incident_model.dart';

part 'map_filter_state.dart';

/// Cubit that manages map filter state and calculates risk level
class MapFilterCubit extends Cubit<MapFilterState> {
  MapFilterCubit()
      : super(
          MapFilterState(
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

  /// Update the time filter
  void updateTimeFilter(TimeFilter filter) {
    emit(state.copyWith(timeFilter: filter));
  }

  /// Toggle a category filter
  void toggleCategory(IncidentCategory category) {
    final newCategories = Set<IncidentCategory>.from(state.selectedCategories);
    if (newCategories.contains(category)) {
      newCategories.remove(category);
    } else {
      newCategories.add(category);
    }
    emit(state.copyWith(selectedCategories: newCategories));
  }

  /// Calculate and update risk level based on filtered incidents
  void updateRiskLevel(List<Incident> filteredIncidents) {
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
