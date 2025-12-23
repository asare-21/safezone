import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:safe_zone/profile/models/user_score_model.dart';

/// Repository for managing user scoring and achievements
class ScoringRepository {

  ScoringRepository({required this.baseUrl, http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();
  final http.Client _httpClient;
  final String baseUrl;

  /// Get user profile and scoring information
  Future<UserScore> getUserProfile(String deviceId) async {
    final url = Uri.parse('$baseUrl/api/scoring/profile/$deviceId/');

    final response = await _httpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return UserScore.fromJson(data);
    } else {
      throw Exception(
        'Failed to load user profile: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Get user badges
  Future<List<Badge>> getUserBadges(String deviceId) async {
    final url = Uri.parse('$baseUrl/api/scoring/profile/$deviceId/badges/');

    final response = await _httpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data is Map && data.containsKey('results')
          ? data['results'] as List
          : data as List;
      return results
          .map((badge) => Badge.fromJson(badge as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to load user badges: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Get leaderboard
  Future<List<UserScore>> getLeaderboard({
    int page = 1,
    int perPage = 100,
  }) async {
    final url = Uri.parse(
      '$baseUrl/api/scoring/leaderboard/?page=$page&per_page=$perPage',
    );

    final response = await _httpClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data is Map && data.containsKey('results')
          ? data['results'] as List
          : data as List;
      return results
          .map((user) => UserScore.fromJson(user as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to load leaderboard: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Confirm an incident
  Future<ConfirmationResponse> confirmIncident(
    int incidentId,
    String deviceId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/api/scoring/incidents/$incidentId/confirm/',
    );

    final response = await _httpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'device_id': deviceId,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return ConfirmationResponse.fromJson(data);
    } else {
      throw Exception(
        'Failed to confirm incident: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Check for nearby unconfirmed incidents
  Future<List<NearbyIncident>> getNearbyIncidents({
    required double latitude,
    required double longitude,
    required String deviceId,
    double radiusKm = 0.5,
    int hours = 24,
  }) async {
    final url = Uri.parse('$baseUrl/api/scoring/incidents/nearby/');

    final response = await _httpClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'latitude': latitude,
        'longitude': longitude,
        'device_id': deviceId,
        'radius_km': radiusKm,
        'hours': hours,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final incidents = data['incidents'] as List;
      return incidents
          .map((incident) => NearbyIncident.fromJson(incident as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(
        'Failed to get nearby incidents: ${response.statusCode} ${response.body}',
      );
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
