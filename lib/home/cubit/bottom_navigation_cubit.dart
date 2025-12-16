import 'package:bloc/bloc.dart';

part 'bottom_navigation_state.dart';

/// Cubit that manages bottom navigation state
class BottomNavigationCubit extends Cubit<BottomNavigationState> {
  BottomNavigationCubit() : super(const BottomNavigationState());

  /// Navigate to a specific tab by index
  void navigateToTab(int index) {
    if (index >= 0 && index <= 3) {
      emit(BottomNavigationState(index: index));
    }
  }

  /// Navigate to Map tab (index 0)
  void navigateToMap() => navigateToTab(0);

  /// Navigate to Alerts tab (index 1)
  void navigateToAlerts() => navigateToTab(1);

  /// Navigate to Guide tab (index 2)
  void navigateToGuide() => navigateToTab(2);

  /// Navigate to Settings tab (index 3)
  void navigateToSettings() => navigateToTab(3);
}
