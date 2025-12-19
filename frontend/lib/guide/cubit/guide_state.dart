import 'package:equatable/equatable.dart';
import 'package:safe_zone/guide/models/models.dart';

/// Represents the state of the guides feature
abstract class GuideState extends Equatable {
  const GuideState();

  @override
  List<Object?> get props => [];
}

/// Initial state - no guides loaded yet
class GuideInitial extends GuideState {
  const GuideInitial();
}

/// Loading guides from the API
class GuideLoading extends GuideState {
  const GuideLoading();
}

/// Successfully loaded guides
class GuideLoaded extends GuideState {
  const GuideLoaded({
    required this.guides,
    required this.guidesBySection,
  });

  final List<Guide> guides;
  final Map<GuideSection, List<Guide>> guidesBySection;

  @override
  List<Object?> get props => [guides, guidesBySection];
}

/// Error loading guides
class GuideError extends GuideState {
  const GuideError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
