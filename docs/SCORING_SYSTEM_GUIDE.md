# Truth Hunter Scoring System - Implementation Guide

## Overview
The Truth Hunter Scoring System has been implemented in the SafeZone backend with Django REST Framework. This document provides a comprehensive guide on how the system works and how to integrate it with the Flutter frontend.

## Backend Implementation ✅

### Models

#### 1. UserProfile
Tracks user scores, tiers, and achievements.

**Fields:**
- `device_id` (encrypted) - Unique identifier for privacy
- `device_id_hash` - SHA256 hash for lookups (encrypted fields don't support filtering)
- `total_points` - Total points earned
- `reports_count` - Number of incidents reported
- `confirmations_count` - Number of confirmations made
- `current_tier` - Current tier level (1-7)
- `verified_reports` - Number of verified reports
- `created_at`, `updated_at` - Timestamps

**Key Methods:**
- `add_report_points(incident)` - Awards 10 base points + 2 bonus for reports within 1 hour
- `add_confirmation_points()` - Awards 5 points per confirmation (max 10 per incident)
- `update_tier()` - Updates tier based on points
- Properties: `tier_name`, `tier_icon`, `accuracy_percentage`

#### 2. IncidentConfirmation
Tracks user confirmations of incidents to prevent duplicates and award points.

**Fields:**
- `incident` - Foreign key to Incident
- `device_id` (encrypted) - User identifier
- `device_id_hash` - For lookups
- `confirmed_at` - Timestamp

**Constraints:**
- Unique together: (`incident`, `device_id_hash`) - prevents duplicate confirmations

#### 3. Badge
Tracks special achievements earned by users.

**Badge Types:**
- `first_responder` - First to report in your zone
- `truth_triangulator` - 5+ confirmations earned
- `night_owl` - Active during late-night hours
- `accuracy_ace` - 95%+ verification accuracy

### API Endpoints

#### 1. Get User Profile
```
GET /api/scoring/profile/{device_id}/
```
Returns complete user profile with scoring data, badges, and tier information.

**Response Example:**
```json
{
  "id": 1,
  "total_points": 125,
  "reports_count": 10,
  "confirmations_count": 15,
  "current_tier": 2,
  "tier_name": "Neighborhood Watch",
  "tier_icon": "🛡️",
  "tier_reward": "Bronze shield",
  "verified_reports": 9,
  "accuracy_percentage": 90.0,
  "badges": [
    {
      "id": 1,
      "badge_type": "truth_triangulator",
      "badge_display_name": "Truth Triangulator",
      "badge_icon": "✅",
      "badge_description": "5+ confirmations earned",
      "earned_at": "2025-01-15T10:30:00Z"
    }
  ],
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-01-15T10:30:00Z"
}
```

#### 2. Get User Badges
```
GET /api/scoring/profile/{device_id}/badges/
```
Returns list of badges earned by the user.

#### 3. Get Leaderboard
```
GET /api/scoring/leaderboard/
```
Returns top 100 users ordered by total points.

**Query Parameters:**
- `page` (optional) - Page number for pagination
- `per_page` (optional) - Results per page (max 100)

#### 4. Confirm Incident
```
POST /api/scoring/incidents/{incident_id}/confirm/
```

**Request Body:**
```json
{
  "device_id": "user_device_identifier"
}
```

**Response Example:**
```json
{
  "points_earned": 5,
  "total_points": 130,
  "tier_changed": false,
  "new_tier": null,
  "tier_name": null,
  "tier_icon": null,
  "message": "Incident confirmed successfully!",
  "confirmation_count": 3
}
```

#### 5. Create Incident (Updated)
```
POST /api/incidents/
```

**Request Body (with scoring):**
```json
{
  "category": "theft",
  "latitude": 37.7749,
  "longitude": -122.4194,
  "title": "Theft Incident",
  "description": "Description here",
  "device_id": "user_device_identifier"
}
```

The `device_id` field is optional. If provided, the system will automatically:
1. Create or get the user's profile
2. Award 10 base points + 2 bonus points if reported within 1 hour
3. Update the user's tier if threshold is crossed

### Tier System

| Tier | Points | Title | Icon | Reward |
|------|--------|-------|------|--------|
| 1 | 0-50 | Fresh Eye Scout | 👁️ | "New Watcher" badge |
| 2 | 51-150 | Neighborhood Watch | 🛡️ | Bronze shield |
| 3 | 151-300 | Urban Detective | 🔍 | Silver magnifier |
| 4 | 301-500 | Community Guardian | 🦸 | Gold hero badge |
| 5 | 501-800 | Truth Blazer | 🔥 | Animated fire icon |
| 6 | 801-1200 | Safety Sentinel | 👑 | Crown with sparkles |
| 7 | 1200+ | Legendary Watchmaster | 🌟 | Legendary frame |

### Scoring Formula

**Report Points:**
```
Base: 10 points
Time Bonus: +2 points (if reported within 1 hour)
Total: 10-12 points per report
```

**Confirmation Points:**
```
Per confirmation: 5 points
Max confirmations counted per incident: 10
Total: up to 50 points per incident (if all 10 confirmations are made)
```

## Flutter Frontend (Partially Implemented) 🚧

### Models Created ✅

1. **UserScore** - Complete model with all scoring fields
2. **Badge** - Model for user achievements
3. **ConfirmationResponse** - Response model for confirmation actions

### Repository Created ✅

**ScoringRepository** provides methods to:
- `getUserProfile(deviceId)` - Fetch user profile
- `getUserBadges(deviceId)` - Fetch user badges
- `getLeaderboard()` - Fetch leaderboard
- `confirmIncident(incidentId, deviceId)` - Confirm an incident

### Integration Steps (To Complete)

#### 1. Create Scoring Cubit

Create `/frontend/lib/profile/cubit/scoring_cubit.dart`:

```dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:safe_zone/profile/models/user_score_model.dart';
import 'package:safe_zone/profile/repository/scoring_repository.dart';

// State
abstract class ScoringState extends Equatable {
  const ScoringState();

  @override
  List<Object?> get props => [];
}

class ScoringInitial extends ScoringState {}

class ScoringLoading extends ScoringState {}

class ScoringLoaded extends ScoringState {
  final UserScore userScore;

  const ScoringLoaded(this.userScore);

  @override
  List<Object?> get props => [userScore];
}

class ScoringError extends ScoringState {
  final String message;

  const ScoringError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class ScoringCubit extends Cubit<ScoringState> {
  final ScoringRepository _repository;

  ScoringCubit(this._repository) : super(ScoringInitial());

  Future<void> loadUserProfile(String deviceId) async {
    emit(ScoringLoading());
    try {
      final userScore = await _repository.getUserProfile(deviceId);
      emit(ScoringLoaded(userScore));
    } catch (e) {
      emit(ScoringError(e.toString()));
    }
  }

  Future<ConfirmationResponse?> confirmIncident(
    int incidentId,
    String deviceId,
  ) async {
    try {
      final response = await _repository.confirmIncident(incidentId, deviceId);
      
      // Reload profile to get updated points
      await loadUserProfile(deviceId);
      
      return response;
    } catch (e) {
      emit(ScoringError(e.toString()));
      return null;
    }
  }
}
```

#### 2. Update Profile Screen

Update `/frontend/lib/profile/view/profile.dart`:

Replace hardcoded values with BlocBuilder:

```dart
// In ProfileScreen build method, wrap profile card with BlocProvider
BlocProvider(
  create: (context) => ScoringCubit(ScoringRepository())
    ..loadUserProfile(deviceId), // Get device_id from device_info_plus
  child: BlocBuilder<ScoringCubit, ScoringState>(
    builder: (context, state) {
      if (state is ScoringLoaded) {
        return _buildUserProfileCard(theme, context, state.userScore);
      } else if (state is ScoringLoading) {
        return CircularProgressIndicator();
      } else if (state is ScoringError) {
        return Text('Error: ${state.message}');
      }
      return SizedBox();
    },
  ),
)

// Update _buildUserProfileCard to accept UserScore parameter
Widget _buildUserProfileCard(
  ThemeData theme,
  BuildContext context,
  UserScore userScore,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      // ... existing decoration
      child: Column(
        children: [
          // ... existing avatar row
          const SizedBox(height: 16),
          // Trust Score - use real data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${userScore.tierIcon} ${userScore.tierName}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${userScore.accuracyPercentage.toStringAsFixed(0)}% accuracy',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _lightBlueBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${userScore.totalPoints} pts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar - use real progress
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: userScore.progressToNextTier,
              minHeight: 8,
              backgroundColor: theme.dividerColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          // Add stats row
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: LineIcons.flag,
                label: 'Reports',
                value: userScore.reportsCount.toString(),
                theme: theme,
              ),
              _buildStatItem(
                icon: LineIcons.check,
                label: 'Confirms',
                value: userScore.confirmationsCount.toString(),
                theme: theme,
              ),
              _buildStatItem(
                icon: LineIcons.award,
                label: 'Badges',
                value: (userScore.badges?.length ?? 0).toString(),
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildStatItem({
  required IconData icon,
  required String label,
  required String value,
  required ThemeData theme,
}) {
  return Column(
    children: [
      Icon(icon, size: 20, color: theme.colorScheme.primary),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    ],
  );
}
```

#### 3. Update Incident Reporting

Update incident reporting to include device_id:

```dart
// In incident reporting cubit/repository
import 'package:device_info_plus/device_info_plus.dart';

Future<String> _getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id;
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor ?? '';
  }
  return '';
}

// When creating incident
final deviceId = await _getDeviceId();
final response = await http.post(
  Uri.parse('$apiUrl/api/incidents/'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({
    'category': category,
    'latitude': latitude,
    'longitude': longitude,
    'title': title,
    'description': description,
    'device_id': deviceId, // Add this
  }),
);
```

## Testing

### Backend Tests ✅

All tests passing:
- User profile creation
- Report points awarded
- Time bonus points
- Confirmation points
- Duplicate confirmation prevention
- Tier progression
- Truth Triangulator badge earning
- Leaderboard ordering
- Accuracy percentage calculation
- Max confirmations limit

Run tests with:
```bash
cd backend/safezone_backend
python manage.py test scoring
```

### Manual Testing

1. **Create a report:**
   ```bash
   curl -X POST http://localhost:8000/api/incidents/ \
     -H "Content-Type: application/json" \
     -d '{
       "category": "theft",
       "latitude": 37.7749,
       "longitude": -122.4194,
       "title": "Test Report",
       "device_id": "test_device_123"
     }'
   ```

2. **Get user profile:**
   ```bash
   curl http://localhost:8000/api/scoring/profile/test_device_123/
   ```

3. **Confirm incident:**
   ```bash
   curl -X POST http://localhost:8000/api/scoring/incidents/1/confirm/ \
     -H "Content-Type: application/json" \
     -d '{"device_id": "test_device_456"}'
   ```

## Security Considerations

1. **Device ID Encryption:** All device IDs are encrypted using Django's encrypted model fields
2. **Hash-based Lookups:** Device ID hashes (SHA256) are used for queries to maintain performance while preserving privacy
3. **Anti-Gaming Measures:**
   - Unique constraint prevents duplicate confirmations
   - Max 10 confirmations counted per incident
   - Time-based bonuses encourage timely reporting

## Future Enhancements (Phase 2 & 3)

### Phase 2:
- Daily challenges
- Weekly leaderboards with rankings
- Notification badges for level-ups
- Badge gallery screen

### Phase 3:
- Special events
- Team features
- Confetti animations for level-ups
- Sound effects for achievements
- Official verification multiplier (×1.5)

## Notes

- The backend uses SQLite for development; consider PostgreSQL for production
- Device IDs should be obtained using device_info_plus package in Flutter
- Consider implementing caching for leaderboard queries in production
- Badge earning logic currently only checks Truth Triangulator; implement other badges as needed

## Support

For issues or questions, please refer to:
- Backend tests: `/backend/safezone_backend/scoring/tests.py`
- API endpoints: `/backend/safezone_backend/scoring/urls.py`
- Models: `/backend/safezone_backend/scoring/models.py`
- Flutter models: `/frontend/lib/profile/models/user_score_model.dart`
