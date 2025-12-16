part of 'alert_filter_cubit.dart';

/// Quick filter presets for common filtering scenarios
enum QuickFilter {
  all,
  highSeverity,
  recent,
  nearby,
}

/// Default filter values for alerts
class AlertFilterDefaults {
  const AlertFilterDefaults._();

  static const Set<AlertSeverity> severities = {
    AlertSeverity.high,
    AlertSeverity.medium,
    AlertSeverity.low,
    AlertSeverity.info,
  };
  static const Set<AlertType> types = {
    AlertType.highRisk,
    AlertType.theft,
    AlertType.eventCrowd,
    AlertType.trafficCleared,
  };
  static const AlertTimeFilter timeFilter = AlertTimeFilter.all;
  static const QuickFilter quickFilter = QuickFilter.all;
}

/// Represents the state of alert filters
class AlertFilterState {
  const AlertFilterState({
    this.selectedSeverities = AlertFilterDefaults.severities,
    this.selectedTypes = AlertFilterDefaults.types,
    this.selectedTimeFilter = AlertFilterDefaults.timeFilter,
    this.selectedQuickFilter = AlertFilterDefaults.quickFilter,
  });

  /// Currently selected severity filters
  final Set<AlertSeverity> selectedSeverities;

  /// Currently selected alert type filters
  final Set<AlertType> selectedTypes;

  /// Currently selected time filter
  final AlertTimeFilter selectedTimeFilter;

  /// Currently selected quick filter preset
  final QuickFilter selectedQuickFilter;

  /// Creates a copy of this state with updated values
  AlertFilterState copyWith({
    Set<AlertSeverity>? selectedSeverities,
    Set<AlertType>? selectedTypes,
    AlertTimeFilter? selectedTimeFilter,
    QuickFilter? selectedQuickFilter,
  }) {
    return AlertFilterState(
      selectedSeverities: selectedSeverities ?? this.selectedSeverities,
      selectedTypes: selectedTypes ?? this.selectedTypes,
      selectedTimeFilter: selectedTimeFilter ?? this.selectedTimeFilter,
      selectedQuickFilter: selectedQuickFilter ?? this.selectedQuickFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AlertFilterState &&
        _setEquals(other.selectedSeverities, selectedSeverities) &&
        _setEquals(other.selectedTypes, selectedTypes) &&
        other.selectedTimeFilter == selectedTimeFilter &&
        other.selectedQuickFilter == selectedQuickFilter;
  }

  @override
  int get hashCode =>
      Object.hash(
        selectedSeverities,
        selectedTypes,
        selectedTimeFilter,
        selectedQuickFilter,
      );

  /// Helper method to compare sets for equality
  bool _setEquals<T>(Set<T> a, Set<T> b) {
    if (a.length != b.length) return false;
    return a.every(b.contains);
  }
}
