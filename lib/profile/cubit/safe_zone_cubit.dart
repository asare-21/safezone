import 'package:bloc/bloc.dart';
import 'package:safe_zone/profile/cubit/safe_zone_state.dart';
import 'package:safe_zone/profile/models/safe_zone_model.dart';
import 'package:safe_zone/profile/repository/safe_zone_repository.dart';

class SafeZoneCubit extends Cubit<SafeZoneState> {
  SafeZoneCubit({SafeZoneRepository? repository})
    : _repository = repository ?? SafeZoneRepository(),
      super(const SafeZoneState()) {
    loadSafeZones();
  }

  final SafeZoneRepository _repository;

  /// Load all safe zones from repository
  Future<void> loadSafeZones() async {
    emit(state.copyWith(status: SafeZoneStatus.loading));

    try {
      final zones = await _repository.loadSafeZones();
      emit(
        state.copyWith(
          status: SafeZoneStatus.success,
          safeZones: zones,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SafeZoneStatus.error,
          errorMessage: 'Failed to load safe zones: $e',
        ),
      );
    }
  }

  /// Add a new safe zone
  Future<void> addSafeZone(SafeZone safeZone) async {
    try {
      await _repository.addSafeZone(safeZone);
      await loadSafeZones();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SafeZoneStatus.error,
          errorMessage: 'Failed to add safe zone: $e',
        ),
      );
    }
  }

  /// Update an existing safe zone
  Future<void> updateSafeZone(SafeZone safeZone) async {
    try {
      await _repository.updateSafeZone(safeZone);
      await loadSafeZones();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SafeZoneStatus.error,
          errorMessage: 'Failed to update safe zone: $e',
        ),
      );
    }
  }

  /// Delete a safe zone
  Future<void> deleteSafeZone(String id) async {
    try {
      await _repository.deleteSafeZone(id);
      await loadSafeZones();
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SafeZoneStatus.error,
          errorMessage: 'Failed to delete safe zone: $e',
        ),
      );
    }
  }

  /// Toggle safe zone active status
  Future<void> toggleSafeZone(String id) async {
    try {
      final zone = state.safeZones.firstWhere(
        (z) => z.id == id,
        orElse: () => throw Exception('Safe zone not found'),
      );
      await updateSafeZone(zone.copyWith(isActive: !zone.isActive));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: SafeZoneStatus.error,
          errorMessage: 'Failed to toggle safe zone: $e',
        ),
      );
    }
  }
}
