part of 'bottom_navigation_cubit.dart';

/// Represents the state of bottom navigation
class BottomNavigationState {
  const BottomNavigationState({this.index = 0});

  /// Current navigation index
  final int index;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BottomNavigationState && other.index == index;
  }

  @override
  int get hashCode => index.hashCode;
}
