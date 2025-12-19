import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safe_zone/guide/models/models.dart';

/// Service for interacting with the guides API
class GuideApiService {
  GuideApiService({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _httpClient;

  /// Fetch all guides from the API
  Future<List<Guide>> getGuides() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/guides/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>;

        return results
            .map((json) => Guide.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load guides: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching guides: $e');
    }
  }

  /// Get a specific guide by ID
  Future<Guide> getGuide(int id) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/api/guides/$id/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Guide.fromJson(data);
      } else {
        throw Exception(
          'Failed to load guide: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching guide: $e');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
