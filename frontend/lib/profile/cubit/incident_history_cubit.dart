import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:safe_zone/profile/models/user_score_model.dart';
import 'package:safe_zone/profile/repository/scoring_repository.dart';

/// States for incident history
abstract class IncidentHistoryState extends Equatable {
  const IncidentHistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state before loading
class IncidentHistoryInitial extends IncidentHistoryState {}

/// Loading state while fetching data
class IncidentHistoryLoading extends IncidentHistoryState {}

/// Loaded state with user incidents
class IncidentHistoryLoaded extends IncidentHistoryState {
  const IncidentHistoryLoaded(this.incidents);

  final List<ReportedIncident> incidents;

  @override
  List<Object?> get props => [incidents];
}

/// Error state when something goes wrong
class IncidentHistoryError extends IncidentHistoryState {
  const IncidentHistoryError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Cubit for managing user incident history state
class IncidentHistoryCubit extends Cubit<IncidentHistoryState> {
  IncidentHistoryCubit(this._repository) : super(IncidentHistoryInitial());

  final ScoringRepository _repository;

  /// Load user's reported incidents
  Future<void> loadUserIncidents(String deviceId) async {
    emit(IncidentHistoryLoading());
    try {
      final incidents = await _repository.getUserIncidents(deviceId);
      emit(IncidentHistoryLoaded(incidents));
    } catch (e) {
      emit(IncidentHistoryError(e.toString()));
    }
  }

  /// Refresh user incidents
  Future<void> refresh(String deviceId) async {
    await loadUserIncidents(deviceId);
  }
}
