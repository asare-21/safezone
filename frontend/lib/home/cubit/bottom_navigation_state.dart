part of 'bottom_navigation_cubit.dart';

/// Represents the state of bottom navigation
class BottomNavigationState extends Equatable {
  const BottomNavigationState({this.index = 0});

  /// Current navigation index
  final int index;

  @override
  List<Object?> get props => [index];
}
