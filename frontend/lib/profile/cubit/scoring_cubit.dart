import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:safe_zone/profile/models/user_score_model.dart';
import 'package:safe_zone/profile/repository/scoring_repository.dart';

/// States for scoring system
abstract class ScoringState extends Equatable {
  const ScoringState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class ScoringInitial extends ScoringState {}

/// Loading state while fetching data
class ScoringLoading extends ScoringState {}

/// Loaded state with user score data
class ScoringLoaded extends ScoringState {
  const ScoringLoaded(this.userScore);

  final UserScore userScore;

  @override
  List<Object?> get props => [userScore];
}

/// Error state when something goes wrong
class ScoringError extends ScoringState {
  const ScoringError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Cubit for managing scoring system state
class ScoringCubit extends Cubit<ScoringState> {
  ScoringCubit(this._repository) : super(ScoringInitial());

  final ScoringRepository _repository;

  /// Load user profile and scoring data
  Future<void> loadUserProfile(String deviceId) async {
    emit(ScoringLoading());
    try {
      final userScore = await _repository.getUserProfile(deviceId);
      emit(ScoringLoaded(userScore));
    } catch (e) {
      emit(ScoringError(e.toString()));
    }
  }

  /// Confirm an incident and update scoring
  Future<ConfirmationResponse?> confirmIncident(
    int incidentId,
    String deviceId,
  ) async {
    try {
      final response = await _repository.confirmIncident(
        incidentId,
        deviceId,
      );

      // Reload profile to get updated points
      await loadUserProfile(deviceId);

      return response;
    } catch (e) {
      emit(ScoringError(e.toString()));
      return null;
    }
  }

  /// Refresh user profile data
  Future<void> refresh(String deviceId) async {
    await loadUserProfile(deviceId);
  }
}
