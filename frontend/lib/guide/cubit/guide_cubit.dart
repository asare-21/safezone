import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_zone/guide/cubit/guide_state.dart';
import 'package:safe_zone/guide/models/models.dart';
import 'package:safe_zone/guide/services/services.dart';

/// Cubit for managing guide state
class GuideCubit extends Cubit<GuideState> {
  GuideCubit({required GuideApiService apiService})
      : _apiService = apiService,
        super(const GuideInitial());

  final GuideApiService _apiService;

  /// Load all guides from the API
  Future<void> loadGuides() async {
    emit(const GuideLoading());

    try {
      final guides = await _apiService.getGuides();

      // Group guides by section
      final guidesBySection = <GuideSection, List<Guide>>{};
      for (final guide in guides) {
        if (!guidesBySection.containsKey(guide.section)) {
          guidesBySection[guide.section] = [];
        }
        guidesBySection[guide.section]!.add(guide);
      }

      emit(GuideLoaded(
        guides: guides,
        guidesBySection: guidesBySection,
      ));
    } catch (e) {
      emit(GuideError('Failed to load guides: $e'));
    }
  }

  /// Refresh guides
  Future<void> refreshGuides() async {
    await loadGuides();
  }
}
