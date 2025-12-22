import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_zone/alerts/models/alert_model.dart';
import 'package:safe_zone/alerts/services/alert_api_service.dart';

part 'alerts_state.dart';

/// Cubit for managing alerts data and API communication
class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit({
    required AlertApiService alertApiService,
  }) : _alertApiService = alertApiService,
       super(const AlertsInitial());

  final AlertApiService _alertApiService;
  Timer? _refreshTimer;

  /// Fetch alerts from the API
  Future<void> fetchAlerts({
    AlertSeverity? severity,
    AlertType? alertType,
    int? hours,
    LatLng? userLocation,
    double? radiusKm,
  }) async {
    try {
      emit(const AlertsLoading());

      final alerts = await _alertApiService.getAlerts(
        severity: severity,
        alertType: alertType,
        hours: hours,
        userLocation: userLocation,
        radiusKm: radiusKm,
      );

      emit(AlertsLoaded(alerts: alerts, lastUpdated: DateTime.now()));
    } on Exception catch (e) {
      debugPrint('Error fetching alerts: $e');
      emit(AlertsError(message: e.toString()));
    }
  }

  /// Generate alerts based on user location and nearby incidents
  Future<void> generateAlerts({
    required LatLng userLocation,
    double radiusKm = 5.0,
    int hours = 24,
  }) async {
    try {
      emit(const AlertsLoading());

      final alerts = await _alertApiService.generateAlerts(
        userLocation: userLocation,
        radiusKm: radiusKm,
        hours: hours,
      );

      emit(AlertsLoaded(alerts: alerts, lastUpdated: DateTime.now()));
    } catch (e) {
      debugPrint('Error generating alerts: $e');
      emit(AlertsError(message: e.toString()));
    }
  }

  /// Refresh alerts (used for pull-to-refresh)
  Future<void> refreshAlerts({
    AlertSeverity? severity,
    AlertType? alertType,
    int? hours,
    LatLng? userLocation,
    double? radiusKm,
  }) async {
    // Keep current alerts while refreshing
    if (state is AlertsLoaded) {
      final currentState = state as AlertsLoaded;
      emit(currentState.copyWith(isRefreshing: true));
    }

    try {
      final alerts = await _alertApiService.getAlerts(
        severity: severity,
        alertType: alertType,
        hours: hours,
        userLocation: userLocation,
        radiusKm: radiusKm,
      );

      emit(
        AlertsLoaded(
          alerts: alerts,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('Error refreshing alerts: $e');
      // Keep previous data on refresh error
      if (state is AlertsLoaded) {
        final currentState = state as AlertsLoaded;
        emit(
          currentState.copyWith(
            isRefreshing: false,
            errorMessage: 'Failed to refresh: $e',
          ),
        );
      } else {
        emit(AlertsError(message: e.toString()));
      }
    }
  }

  /// Start auto-refresh timer (every 30 seconds)
  void startAutoRefresh({
    Duration interval = const Duration(seconds: 30),
    AlertSeverity? severity,
    AlertType? alertType,
    int? hours,
    LatLng? userLocation,
    double? radiusKm,
  }) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) {
      refreshAlerts(
        severity: severity,
        alertType: alertType,
        hours: hours,
        userLocation: userLocation,
        radiusKm: radiusKm,
      );
    });
  }

  /// Stop auto-refresh timer
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  Future<void> close() {
    stopAutoRefresh();
    return super.close();
  }
}
