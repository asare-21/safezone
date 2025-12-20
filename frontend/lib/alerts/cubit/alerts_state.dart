part of 'alerts_cubit.dart';

/// Base state for alerts
abstract class AlertsState extends Equatable {
  const AlertsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any alerts are loaded
class AlertsInitial extends AlertsState {
  const AlertsInitial();
}

/// Loading state while fetching alerts
class AlertsLoading extends AlertsState {
  const AlertsLoading();
}

/// Successfully loaded alerts
class AlertsLoaded extends AlertsState {
  const AlertsLoaded({
    required this.alerts,
    required this.lastUpdated,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final List<Alert> alerts;
  final DateTime lastUpdated;
  final bool isRefreshing;
  final String? errorMessage;

  AlertsLoaded copyWith({
    List<Alert>? alerts,
    DateTime? lastUpdated,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return AlertsLoaded(
      alerts: alerts ?? this.alerts,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [alerts, lastUpdated, isRefreshing, errorMessage];
}

/// Error state when alert fetching fails
class AlertsError extends AlertsState {
  const AlertsError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
