import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'profile_state.dart';

/// Cubit that manages profile settings
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({SharedPreferences? sharedPreferences})
      : _sharedPreferences = sharedPreferences,
        super(const ProfileState());

  final SharedPreferences? _sharedPreferences;

  static const String _alertRadiusKey = 'alert_radius';

  /// Load saved settings from persistent storage
  Future<void> loadSettings() async {
    emit(state.copyWith(isLoading: true));

    try {
      final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
      final savedRadius = prefs.getDouble(_alertRadiusKey) ?? 2.5;

      emit(state.copyWith(
        alertRadius: savedRadius,
        isLoading: false,
      ));
    } catch (e) {
      // If loading fails, keep default value
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Update the alert radius setting
  Future<void> updateAlertRadius(double radius) async {
    if (radius < 0.5 || radius > 10) {
      return; // Invalid radius
    }

    emit(state.copyWith(alertRadius: radius));

    try {
      final prefs = _sharedPreferences ?? await SharedPreferences.getInstance();
      await prefs.setDouble(_alertRadiusKey, radius);
    } catch (e) {
      // Persistence failed, but state is already updated
      // Could emit an error state here if needed
    }
  }
}
