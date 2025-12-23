# Testing Guide: Creator Confirmation Prevention

## Overview
This document describes how to test that incident creators cannot confirm their own incidents.

## What Was Changed

### Backend Changes
1. **Incident Model** - Added `reporter_device_id_hash` field to track who created each incident
2. **Incident Creation** - Modified to store the reporter's device ID hash when an incident is created
3. **Nearby Incidents API** - Updated to filter out incidents created by the requesting user
4. **Tests** - Added comprehensive tests to verify the feature works correctly

### Frontend Changes
1. **IncidentApiService** - Updated to send device_id when creating incidents
2. **MapScreen** - Added device ID retrieval and passes it to the incident creation API

## How to Test

### Automated Tests
All automated tests have been added and are passing:

```bash
cd backend/safezone_backend
python manage.py test scoring incident_reporting
```

Key tests:
- `test_nearby_incidents_excludes_creator` - Verifies creators don't see their own incidents
- `test_nearby_incidents_excludes_already_confirmed` - Verifies confirmed incidents are excluded

### Manual Testing Steps

#### Prerequisites
1. Backend server running on localhost:8000
2. Flutter app running on a device or emulator
3. Location permissions granted

#### Test Scenario 1: Creator Cannot Confirm Own Incident
1. **Setup**: Open the app on Device A
2. **Action**: Report an incident at your current location
3. **Expected**: The incident is created successfully
4. **Action**: Stay near the reported incident (within 500m)
5. **Expected**: NO confirmation dialog appears for your own incident
6. **Verify**: Check that the incident appears on the map but you don't get prompted to confirm it

#### Test Scenario 2: Other Users Can Confirm Incident
1. **Setup**: Use Device A to report an incident
2. **Action**: Open the app on Device B and navigate to within 500m of the incident
3. **Expected**: Device B receives a confirmation dialog for the incident
4. **Action**: Confirm the incident on Device B
5. **Expected**: Confirmation succeeds and points are awarded to Device B
6. **Verify**: Device B should not see the confirmation dialog again after confirming

#### Test Scenario 3: Legacy Incidents (No Reporter)
1. **Setup**: Create an incident directly in the database without a reporter_device_id_hash
2. **Action**: Open the app and navigate near the incident
3. **Expected**: Confirmation dialog appears (backwards compatibility maintained)

### API Testing

You can test the API directly using curl:

#### Create an Incident with Device ID
```bash
curl -X POST http://localhost:8000/api/incidents/ \
  -H "Content-Type: application/json" \
  -d '{
    "category": "theft",
    "latitude": 37.7749,
    "longitude": -122.4194,
    "title": "Test Theft",
    "description": "Test description",
    "device_id": "test_device_123"
  }'
```

#### Check Nearby Incidents (Should Exclude Creator's Incidents)
```bash
curl -X POST http://localhost:8000/api/scoring/incidents/nearby/ \
  -H "Content-Type: application/json" \
  -d '{
    "latitude": 37.7749,
    "longitude": -122.4194,
    "device_id": "test_device_123",
    "radius_km": 1.0
  }'
```

The response should NOT include the incident created by `test_device_123`.

## Expected Behavior

### Before the Fix
- Users could see and confirm their own incidents
- This allowed gaming the system by creating and confirming your own reports

### After the Fix
- Users cannot see confirmation prompts for incidents they created
- Only other users within 500m can confirm an incident
- Legacy incidents (created before this fix) can still be confirmed by anyone
- The system maintains integrity and prevents gaming

## Database Migration

The following migration was created:
- `incident_reporting/migrations/0002_incident_reporter_device_id_hash.py`

This adds the `reporter_device_id_hash` field to existing incidents (as NULL for legacy data).

## Rollback Plan

If issues are discovered:
1. Revert the migration:
   ```bash
   python manage.py migrate incident_reporting 0001_initial
   ```
2. Revert the code changes
3. Deploy the previous version

## Performance Considerations

- The new field is indexed for efficient querying
- No significant performance impact expected
- Legacy incidents without reporter tracking are handled gracefully

## Privacy & Security

- Device IDs are hashed using SHA256 before storage
- Only the hash is used for comparison, maintaining user privacy
- No new PII is collected; we're using existing device ID infrastructure
