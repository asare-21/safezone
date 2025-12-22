import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/guide/guide.dart';

class MockGuideApiService extends Mock implements GuideApiService {}

void main() {
  group('GuideCubit', () {
    late GuideApiService mockApiService;
    late GuideCubit guideCubit;

    setUp(() {
      mockApiService = MockGuideApiService();
      guideCubit = GuideCubit(apiService: mockApiService);
    });

    tearDown(() {
      guideCubit.close();
    });

    test('initial state is GuideInitial', () {
      expect(guideCubit.state, const GuideInitial());
    });

    group('loadGuides', () {
      final testGuides = [
        Guide(
          id: 1,
          section: GuideSection.howItWorks,
          title: 'Crowdsourced Safety',
          content: 'SafeZone uses community-reported incidents.',
          icon: 'shield',
          order: 1,
          isActive: true,
          createdAt: DateTime(2025, 12, 22),
          updatedAt: DateTime(2025, 12, 22),
        ),
        Guide(
          id: 2,
          section: GuideSection.reporting,
          title: 'Report Incidents',
          content: 'How to report incidents.',
          icon: 'report',
          order: 1,
          isActive: true,
          createdAt: DateTime(2025, 12, 22),
          updatedAt: DateTime(2025, 12, 22),
        ),
      ];

      blocTest<GuideCubit, GuideState>(
        'emits [GuideLoading, GuideLoaded] when guides are loaded successfully',
        build: () {
          when(() => mockApiService.getGuides())
              .thenAnswer((_) async => testGuides);
          return guideCubit;
        },
        act: (cubit) => cubit.loadGuides(),
        expect: () => [
          const GuideLoading(),
          isA<GuideLoaded>()
              .having((state) => state.guides.length, 'guides count', 2)
              .having(
                (state) => state.guidesBySection.keys.length,
                'sections count',
                2,
              ),
        ],
        verify: (_) {
          verify(() => mockApiService.getGuides()).called(1);
        },
      );

      blocTest<GuideCubit, GuideState>(
        'groups guides by section correctly',
        build: () {
          when(() => mockApiService.getGuides())
              .thenAnswer((_) async => testGuides);
          return guideCubit;
        },
        act: (cubit) => cubit.loadGuides(),
        verify: (cubit) {
          final state = cubit.state as GuideLoaded;
          expect(state.guidesBySection[GuideSection.howItWorks]?.length, 1);
          expect(state.guidesBySection[GuideSection.reporting]?.length, 1);
        },
      );

      blocTest<GuideCubit, GuideState>(
        'emits [GuideLoading, GuideError] when loading fails',
        build: () {
          when(() => mockApiService.getGuides())
              .thenThrow(Exception('Network error'));
          return guideCubit;
        },
        act: (cubit) => cubit.loadGuides(),
        expect: () => [
          const GuideLoading(),
          isA<GuideError>()
              .having(
                (state) => state.message,
                'error message',
                contains('Failed to load guides'),
              ),
        ],
      );
    });

    group('refreshGuides', () {
      final testGuides = [
        Guide(
          id: 1,
          section: GuideSection.howItWorks,
          title: 'Test Guide',
          content: 'Test content',
          icon: 'info',
          order: 1,
          isActive: true,
          createdAt: DateTime(2025, 12, 22),
          updatedAt: DateTime(2025, 12, 22),
        ),
      ];

      blocTest<GuideCubit, GuideState>(
        'calls loadGuides when refreshGuides is called',
        build: () {
          when(() => mockApiService.getGuides())
              .thenAnswer((_) async => testGuides);
          return guideCubit;
        },
        act: (cubit) => cubit.refreshGuides(),
        expect: () => [
          const GuideLoading(),
          isA<GuideLoaded>(),
        ],
        verify: (_) {
          verify(() => mockApiService.getGuides()).called(1);
        },
      );
    });
  });
}
