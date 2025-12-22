import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:safe_zone/guide/guide.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('GuideApiService', () {
    late GuideApiService apiService;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      apiService = GuideApiService(
        baseUrl: 'http://localhost:8000',
        httpClient: mockHttpClient,
      );
    });

    group('getGuides', () {
      test('returns list of guides on successful response', () async {
        // Arrange
        const responseBody = '''
        {
          "count": 2,
          "next": null,
          "previous": null,
          "results": [
            {
              "id": 1,
              "section": "how_it_works",
              "title": "Crowdsourced Safety",
              "content": "SafeZone uses community-reported incidents.",
              "icon": "shield",
              "order": 1,
              "is_active": true,
              "created_at": "2025-12-22T13:18:19.421374Z",
              "updated_at": "2025-12-22T13:18:19.421379Z"
            },
            {
              "id": 2,
              "section": "how_it_works",
              "title": "Proximity Alerts",
              "content": "Get notified automatically.",
              "icon": "map_marker",
              "order": 2,
              "is_active": true,
              "created_at": "2025-12-22T13:18:19.421387Z",
              "updated_at": "2025-12-22T13:18:19.421392Z"
            }
          ]
        }
        ''';

        when(() => mockHttpClient.get(
              Uri.parse('http://localhost:8000/api/guides/'),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        // Act
        final guides = await apiService.getGuides();

        // Assert
        expect(guides, hasLength(2));
        expect(guides[0].id, 1);
        expect(guides[0].section, GuideSection.howItWorks);
        expect(guides[0].title, 'Crowdsourced Safety');
        expect(guides[0].icon, 'shield');
        expect(guides[1].id, 2);
        expect(guides[1].title, 'Proximity Alerts');
      });

      test('throws exception on failed response', () async {
        // Arrange
        when(() => mockHttpClient.get(
              Uri.parse('http://localhost:8000/api/guides/'),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('Server Error', 500),
        );

        // Act & Assert
        expect(
          () => apiService.getGuides(),
          throwsException,
        );
      });

      test('throws exception on network error', () async {
        // Arrange
        when(() => mockHttpClient.get(
              Uri.parse('http://localhost:8000/api/guides/'),
              headers: any(named: 'headers'),
            )).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => apiService.getGuides(),
          throwsException,
        );
      });
    });

    group('getGuide', () {
      test('returns single guide on successful response', () async {
        // Arrange
        const responseBody = '''
        {
          "id": 1,
          "section": "how_it_works",
          "title": "Crowdsourced Safety",
          "content": "SafeZone uses community-reported incidents.",
          "icon": "shield",
          "order": 1,
          "is_active": true,
          "created_at": "2025-12-22T13:18:19.421374Z",
          "updated_at": "2025-12-22T13:18:19.421379Z"
        }
        ''';

        when(() => mockHttpClient.get(
              Uri.parse('http://localhost:8000/api/guides/1/'),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(responseBody, 200),
        );

        // Act
        final guide = await apiService.getGuide(1);

        // Assert
        expect(guide.id, 1);
        expect(guide.section, GuideSection.howItWorks);
        expect(guide.title, 'Crowdsourced Safety');
        expect(guide.icon, 'shield');
      });

      test('throws exception on 404 response', () async {
        // Arrange
        when(() => mockHttpClient.get(
              Uri.parse('http://localhost:8000/api/guides/999/'),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('Not Found', 404),
        );

        // Act & Assert
        expect(
          () => apiService.getGuide(999),
          throwsException,
        );
      });
    });
  });
}
