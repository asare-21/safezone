import 'package:bloc/bloc.dart';
import 'package:safe_zone/alerts/models/alert_model.dart';

part 'alert_filter_state.dart';

/// Cubit that manages alert filter state
class AlertFilterCubit extends Cubit<AlertFilterState> {
  AlertFilterCubit() : super(const AlertFilterState());

  /// Toggle a severity filter
  void toggleSeverity(AlertSeverity severity) {
    final newSeverities = Set<AlertSeverity>.from(state.selectedSeverities);
    if (newSeverities.contains(severity)) {
      newSeverities.remove(severity);
    } else {
      newSeverities.add(severity);
    }
    emit(state.copyWith(selectedSeverities: newSeverities));
  }

  /// Toggle an alert type filter
  void toggleType(AlertType type) {
    final newTypes = Set<AlertType>.from(state.selectedTypes);
    if (newTypes.contains(type)) {
      newTypes.remove(type);
    } else {
      newTypes.add(type);
    }
    emit(state.copyWith(selectedTypes: newTypes));
  }

  /// Set the time filter
  void setTimeFilter(AlertTimeFilter timeFilter) {
    emit(state.copyWith(selectedTimeFilter: timeFilter));
  }

  /// Reset all filters to defaults
  void resetFilters() {
    emit(const AlertFilterState());
  }

  /// Set a quick filter preset
  void setQuickFilter(QuickFilter filter) {
    emit(state.copyWith(selectedQuickFilter: filter));
  }
}
