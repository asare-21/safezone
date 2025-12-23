# Planned Features - GitHub Issues

This document contains issue templates for the 12 planned features. You can create these issues manually on GitHub or use the GitHub CLI commands at the bottom.

---

## Issue 1: Media Upload for Incident Reports

**Title:** Feature: Media upload for incident reports (camera/gallery)

**Labels:** `enhancement`

**Body:**
```markdown
## Summary
Add the ability for users to attach photos or videos when reporting incidents.

## Feature Description
- Allow users to capture photos using the device camera
- Allow users to select images from their gallery
- Support for multiple image uploads per incident
- Image compression and optimization for network transfer
- Preview images before submitting the report
- Store media files securely with proper encryption

## Acceptance Criteria
- [ ] Camera integration with permission handling
- [ ] Gallery picker implementation
- [ ] Image compression before upload
- [ ] Image preview in incident report form
- [ ] Backend API for media upload
- [ ] Media display in incident details view
- [ ] Proper error handling for failed uploads

## Technical Considerations
- Use `image_picker` Flutter package
- Consider image compression with `flutter_image_compress`
- Store media in cloud storage (S3, Firebase Storage, etc.)
- Implement lazy loading for media in list views
- Add offline queue for media uploads

## Related Documentation
- See `INCIDENT_REPORTING_IMPLEMENTATION.md` for current reporting flow
```

---

## Issue 2: Push Notifications for Incident Proximity

**Title:** Feature: Push notifications for incident proximity

**Labels:** `enhancement`

**Body:**
```markdown
## Summary
Send push notifications to users when they are approaching areas with recent safety incidents.

## Feature Description
- Real-time proximity detection using device location
- Configurable alert radius (0.5km - 10km)
- Category-based notification filtering
- Smart notification throttling to prevent spam
- Background location monitoring
- Rich notifications with incident details

## Acceptance Criteria
- [ ] Background location service implementation
- [ ] Geofencing for incident areas
- [ ] FCM push notification integration
- [ ] User preferences for notification types
- [ ] Notification throttling logic
- [ ] Rich notification with action buttons
- [ ] Battery optimization considerations

## Technical Considerations
- Use Firebase Cloud Messaging (FCM)
- Implement background location with `geolocator`
- Use geofencing with `geofence_service` or custom implementation
- Consider battery impact of location monitoring
- Implement server-side proximity checks

## Related Documentation
- See `PUSH_NOTIFICATIONS.md` for FCM setup
- See `GEOFENCING_IMPLEMENTATION.md` for proximity logic
```

---

## Issue 3: Route Safety Scoring

**Title:** Feature: Route safety scoring

**Labels:** `enhancement`

**Body:**
```markdown
## Summary
Provide safety scores for walking/driving routes based on incident data along the path.

## Feature Description
- Calculate safety score based on incidents along route
- Display color-coded route segments (safe/moderate/caution)
- Suggest alternative safer routes
- Time-of-day safety adjustments
- Historical incident analysis for routes
- Integration with navigation apps

## Acceptance Criteria
- [ ] Route drawing on map
- [ ] Safety score calculation algorithm
- [ ] Visual route segment coloring
- [ ] Alternative route suggestions
- [ ] Time-based safety adjustments
- [ ] Route safety summary display
- [ ] Share route safety report

## Technical Considerations
- Use routing APIs (OSRM, Mapbox, Google Directions)
- Buffer analysis for incidents near route
- Weight recent incidents higher
- Consider incident severity in scoring
- Cache route calculations for performance

## Algorithm Considerations
```
route_safety_score = base_score - Σ(incident_weight × recency_factor × proximity_factor)
```
```

---

## Issue 4: Offline Incident Caching

**Title:** Feature: Offline incident caching

**Labels:** `enhancement`

**Body:**
```markdown
## Summary
Enable the app to work offline by caching incident data locally.

## Feature Description
- Cache incidents for offline viewing
- Queue incident reports when offline
- Automatic sync when connection restored
- Local database for incident storage
- Cache invalidation strategy
- Offline map tile support

## Acceptance Criteria
- [ ] Local database implementation (SQLite/Hive)
- [ ] Incident data caching on load
- [ ] Offline incident report queue
- [ ] Network connectivity monitoring
- [ ] Background sync service
- [ ] Cache size management
- [ ] Conflict resolution for synced data

## Technical Considerations
- Use `sqflite` or `hive` for local storage
- Implement `connectivity_plus` for network monitoring
- Design sync queue with retry logic
- Consider data freshness indicators
- Handle merge conflicts gracefully
```

---

## Issue 5: Admin Moderation Dashboard

**Title:** Feature: Admin moderation dashboard

**Labels:** `enhancement`

**Body:**
```markdown
## Summary
Create an admin dashboard for moderating reported incidents and managing users.

## Feature Description
- Review and approve/reject incidents
- User management (ban, warn, elevate)
- Incident statistics and reports
- False report detection tools
- Bulk moderation actions
- Audit logging

## Acceptance Criteria
- [ ] Admin authentication and authorization
- [ ] Incident review queue
- [ ] Approve/reject/flag actions
- [ ] User management panel
- [ ] Moderation statistics
- [ ] Activity audit log
- [ ] Bulk action support

## Technical Considerations
- Django Admin customization for backend
- Optional: Separate web dashboard (React/Vue)
- Role-based access control (RBAC)
- Implement moderation queue with filters
- Add admin notification for flagged content

## Related Documentation
- Backend admin at `/admin/` endpoint
```

---

## Issue 6: Heatmap Visualization

**Title:** Feature: Heatmap visualization

**Labels:** `enhancement`

**Body:**
```markdown
## Summary
Display incident density as a heatmap overlay on the map.

## Feature Description
- Color-coded heat map based on incident density
- Adjustable intensity and radius
- Time-range filtering for heatmap
- Category-specific heatmaps
- Toggle between markers and heatmap view
- Legend for heatmap colors

## Acceptance Criteria
- [ ] Heatmap layer implementation
- [ ] Intensity calculation based on incidents
- [ ] Time filter integration
- [ ] Category filter integration
- [ ] Toggle control for heatmap view
- [ ] Color legend display
- [ ] Performance optimization for large datasets

## Technical Considerations
- Use `flutter_map_heatmap` or custom implementation
- Cluster data points for performance
- Implement canvas-based rendering
- Cache heatmap tiles at zoom levels
- Consider WebGL rendering for performance
```

---

## Issue 7: Marker Clustering

**Title:** Feature: Marker clustering for incidents

**Labels:** `enhancement`

**Body:**
```markdown
## Summary
Cluster nearby incident markers at lower zoom levels for better map performance and readability.

## Feature Description
- Automatic clustering of nearby markers
- Cluster count display
- Expand clusters on tap or zoom
- Smooth animation for cluster transitions
- Customizable cluster appearance
- Spiderfying for overlapping markers

## Acceptance Criteria
- [ ] Marker clustering implementation
- [ ] Cluster count badges
- [ ] Tap to expand cluster
- [ ] Zoom-based clustering
- [ ] Smooth cluster animations
- [ ] Spiderfy for dense areas
- [ ] Performance testing with 1000+ markers

## Technical Considerations
- Use `flutter_map_marker_cluster` package
- Implement quadtree or grid-based clustering
- Lazy load markers outside viewport
- Cache cluster calculations
- Consider different clustering at zoom levels
```

---

## Issue 8: Pull-to-Refresh

**Title:** Feature: Pull-to-refresh for data refresh

**Labels:** `enhancement`

**Body:**
```markdown
## Summary
Implement pull-to-refresh gesture for refreshing incident data in lists and map view.

## Feature Description
- Pull-to-refresh on alerts list
- Pull-to-refresh on incident history
- Map refresh gesture or button
- Visual loading indicator
- Last updated timestamp display
- Haptic feedback on refresh

## Acceptance Criteria
- [ ] RefreshIndicator on alerts screen
- [ ] RefreshIndicator on incident history
- [ ] Map refresh button
- [ ] Loading state during refresh
- [ ] Last updated timestamp
- [ ] Error handling for failed refresh
- [ ] Haptic feedback implementation

## Technical Considerations
- Use Flutter's `RefreshIndicator` widget
- Implement consistent refresh behavior across screens
- Add debouncing to prevent spam refresh
- Show skeleton loaders during refresh
- Cache previous data during refresh failure
```

---

## Issue 9: Tutorial Overlay

**Title:** Feature: Tutorial overlay for new users

**Labels:** `enhancement`

**Body:**
```markdown
## Summary
Add an interactive tutorial overlay to guide new users through the app features.

## Feature Description
- First-time user onboarding
- Interactive feature highlights
- Step-by-step feature walkthrough
- Skip and replay options
- Progress indicators
- Context-sensitive help tooltips

## Acceptance Criteria
- [ ] Onboarding flow for new users
- [ ] Feature spotlight overlays
- [ ] Interactive tutorial steps
- [ ] Skip tutorial option
- [ ] Replay tutorial from settings
- [ ] Persist tutorial completion state
- [ ] Context help tooltips

## Technical Considerations
- Use `tutorial_coach_mark` or `showcaseview` package
- Store tutorial state in SharedPreferences
- Design non-intrusive overlay UI
- Support tutorial on key features only
- A/B test tutorial effectiveness

## Related Documentation
- Current onboarding in `lib/guide/` directory
```

---

## Issue 10: Analytics and Insights

**Title:** Feature: Analytics and insights dashboard

**Labels:** `enhancement`

**Body:**
```markdown
## Summary
Provide users with analytics and insights about safety trends in their area.

## Feature Description
- Personal activity statistics
- Area safety trends over time
- Incident category breakdown
- Time-of-day safety patterns
- Community contribution metrics
- Weekly/monthly safety reports

## Acceptance Criteria
- [ ] Personal stats dashboard
- [ ] Area incident trends chart
- [ ] Category breakdown pie chart
- [ ] Time pattern visualization
- [ ] User contribution metrics
- [ ] Exportable reports
- [ ] Comparative week-over-week analysis

## Technical Considerations
- Use `fl_chart` for data visualization
- Implement data aggregation on backend
- Cache analytics data locally
- Design clean dashboard UI
- Consider privacy in aggregated data
```

---

## Issue 11: Multi-language Support

**Title:** Feature: Multi-language support (i18n)

**Labels:** `enhancement`

**Body:**
```markdown
## Summary
Add support for multiple languages to make the app accessible to more users.

## Feature Description
- Support for multiple languages
- In-app language switcher
- Automatic language detection
- Localized date/time formats
- RTL language support
- Dynamic string loading

## Initial Languages
- English (default)
- Spanish
- French
- German
- Portuguese
- Arabic (RTL)

## Acceptance Criteria
- [ ] ARB files for each language
- [ ] Language selection in settings
- [ ] System language detection
- [ ] All UI strings internationalized
- [ ] Date/time/number formatting
- [ ] RTL layout support
- [ ] Fallback to English for missing translations

## Technical Considerations
- Use Flutter's `intl` package (already in pubspec)
- Use `l10n.yaml` configuration (already exists)
- Implement lazy loading for translations
- Consider crowdsourced translations
- Test RTL layout thoroughly

## Related Documentation
- See `lib/l10n/` directory for existing setup
```

---

## Issue 12: Dark Mode Themes

**Title:** Feature: Dark mode themes

**Labels:** `enhancement`

**Body:**
```markdown
## Summary
Add dark mode theme support for comfortable nighttime use and battery savings.

## Feature Description
- Dark theme for entire app
- System theme detection
- Manual theme toggle in settings
- Smooth theme transitions
- Map dark mode tiles
- Consistent color palette

## Acceptance Criteria
- [ ] Dark theme color palette
- [ ] Theme toggle in settings
- [ ] System theme detection
- [ ] All screens support dark mode
- [ ] Dark map tiles integration
- [ ] Theme persistence
- [ ] Smooth transition animations

## Technical Considerations
- Use Flutter's `ThemeData` with dark variant
- Store preference in SharedPreferences
- Consider OLED-optimized true black theme
- Test all components in dark mode
- Update shadcn_ui theming for dark mode
```

---

## GitHub CLI Commands

To create all issues at once using the GitHub CLI, run these commands from the repository root:

```bash
# Issue 1: Media Upload
gh issue create --title "Feature: Media upload for incident reports (camera/gallery)" --label "enhancement" --body "## Summary
Add the ability for users to attach photos or videos when reporting incidents.

## Feature Description
- Allow users to capture photos using the device camera
- Allow users to select images from their gallery
- Support for multiple image uploads per incident
- Image compression and optimization for network transfer
- Preview images before submitting the report
- Store media files securely with proper encryption

## Acceptance Criteria
- [ ] Camera integration with permission handling
- [ ] Gallery picker implementation
- [ ] Image compression before upload
- [ ] Image preview in incident report form
- [ ] Backend API for media upload
- [ ] Media display in incident details view
- [ ] Proper error handling for failed uploads

## Technical Considerations
- Use \`image_picker\` Flutter package
- Consider image compression with \`flutter_image_compress\`
- Store media in cloud storage (S3, Firebase Storage, etc.)
- Implement lazy loading for media in list views
- Add offline queue for media uploads"

# Issue 2: Push Notifications
gh issue create --title "Feature: Push notifications for incident proximity" --label "enhancement" --body "## Summary
Send push notifications to users when they are approaching areas with recent safety incidents.

## Feature Description
- Real-time proximity detection using device location
- Configurable alert radius (0.5km - 10km)
- Category-based notification filtering
- Smart notification throttling to prevent spam
- Background location monitoring
- Rich notifications with incident details

## Acceptance Criteria
- [ ] Background location service implementation
- [ ] Geofencing for incident areas
- [ ] FCM push notification integration
- [ ] User preferences for notification types
- [ ] Notification throttling logic
- [ ] Rich notification with action buttons
- [ ] Battery optimization considerations

## Technical Considerations
- Use Firebase Cloud Messaging (FCM)
- Implement background location with \`geolocator\`
- Use geofencing with \`geofence_service\` or custom implementation
- Consider battery impact of location monitoring
- Implement server-side proximity checks"

# Issue 3: Route Safety Scoring
gh issue create --title "Feature: Route safety scoring" --label "enhancement" --body "## Summary
Provide safety scores for walking/driving routes based on incident data along the path.

## Feature Description
- Calculate safety score based on incidents along route
- Display color-coded route segments (safe/moderate/caution)
- Suggest alternative safer routes
- Time-of-day safety adjustments
- Historical incident analysis for routes
- Integration with navigation apps

## Acceptance Criteria
- [ ] Route drawing on map
- [ ] Safety score calculation algorithm
- [ ] Visual route segment coloring
- [ ] Alternative route suggestions
- [ ] Time-based safety adjustments
- [ ] Route safety summary display
- [ ] Share route safety report

## Technical Considerations
- Use routing APIs (OSRM, Mapbox, Google Directions)
- Buffer analysis for incidents near route
- Weight recent incidents higher
- Consider incident severity in scoring
- Cache route calculations for performance"

# Issue 4: Offline Incident Caching
gh issue create --title "Feature: Offline incident caching" --label "enhancement" --body "## Summary
Enable the app to work offline by caching incident data locally.

## Feature Description
- Cache incidents for offline viewing
- Queue incident reports when offline
- Automatic sync when connection restored
- Local database for incident storage
- Cache invalidation strategy
- Offline map tile support

## Acceptance Criteria
- [ ] Local database implementation (SQLite/Hive)
- [ ] Incident data caching on load
- [ ] Offline incident report queue
- [ ] Network connectivity monitoring
- [ ] Background sync service
- [ ] Cache size management
- [ ] Conflict resolution for synced data

## Technical Considerations
- Use \`sqflite\` or \`hive\` for local storage
- Implement \`connectivity_plus\` for network monitoring
- Design sync queue with retry logic
- Consider data freshness indicators
- Handle merge conflicts gracefully"

# Issue 5: Admin Moderation Dashboard
gh issue create --title "Feature: Admin moderation dashboard" --label "enhancement" --body "## Summary
Create an admin dashboard for moderating reported incidents and managing users.

## Feature Description
- Review and approve/reject incidents
- User management (ban, warn, elevate)
- Incident statistics and reports
- False report detection tools
- Bulk moderation actions
- Audit logging

## Acceptance Criteria
- [ ] Admin authentication and authorization
- [ ] Incident review queue
- [ ] Approve/reject/flag actions
- [ ] User management panel
- [ ] Moderation statistics
- [ ] Activity audit log
- [ ] Bulk action support

## Technical Considerations
- Django Admin customization for backend
- Optional: Separate web dashboard (React/Vue)
- Role-based access control (RBAC)
- Implement moderation queue with filters
- Add admin notification for flagged content"

# Issue 6: Heatmap Visualization
gh issue create --title "Feature: Heatmap visualization" --label "enhancement" --body "## Summary
Display incident density as a heatmap overlay on the map.

## Feature Description
- Color-coded heat map based on incident density
- Adjustable intensity and radius
- Time-range filtering for heatmap
- Category-specific heatmaps
- Toggle between markers and heatmap view
- Legend for heatmap colors

## Acceptance Criteria
- [ ] Heatmap layer implementation
- [ ] Intensity calculation based on incidents
- [ ] Time filter integration
- [ ] Category filter integration
- [ ] Toggle control for heatmap view
- [ ] Color legend display
- [ ] Performance optimization for large datasets

## Technical Considerations
- Use \`flutter_map_heatmap\` or custom implementation
- Cluster data points for performance
- Implement canvas-based rendering
- Cache heatmap tiles at zoom levels
- Consider WebGL rendering for performance"

# Issue 7: Marker Clustering
gh issue create --title "Feature: Marker clustering for incidents" --label "enhancement" --body "## Summary
Cluster nearby incident markers at lower zoom levels for better map performance and readability.

## Feature Description
- Automatic clustering of nearby markers
- Cluster count display
- Expand clusters on tap or zoom
- Smooth animation for cluster transitions
- Customizable cluster appearance
- Spiderfying for overlapping markers

## Acceptance Criteria
- [ ] Marker clustering implementation
- [ ] Cluster count badges
- [ ] Tap to expand cluster
- [ ] Zoom-based clustering
- [ ] Smooth cluster animations
- [ ] Spiderfy for dense areas
- [ ] Performance testing with 1000+ markers

## Technical Considerations
- Use \`flutter_map_marker_cluster\` package
- Implement quadtree or grid-based clustering
- Lazy load markers outside viewport
- Cache cluster calculations
- Consider different clustering at zoom levels"

# Issue 8: Pull-to-Refresh
gh issue create --title "Feature: Pull-to-refresh for data refresh" --label "enhancement" --body "## Summary
Implement pull-to-refresh gesture for refreshing incident data in lists and map view.

## Feature Description
- Pull-to-refresh on alerts list
- Pull-to-refresh on incident history
- Map refresh gesture or button
- Visual loading indicator
- Last updated timestamp display
- Haptic feedback on refresh

## Acceptance Criteria
- [ ] RefreshIndicator on alerts screen
- [ ] RefreshIndicator on incident history
- [ ] Map refresh button
- [ ] Loading state during refresh
- [ ] Last updated timestamp
- [ ] Error handling for failed refresh
- [ ] Haptic feedback implementation

## Technical Considerations
- Use Flutter's \`RefreshIndicator\` widget
- Implement consistent refresh behavior across screens
- Add debouncing to prevent spam refresh
- Show skeleton loaders during refresh
- Cache previous data during refresh failure"

# Issue 9: Tutorial Overlay
gh issue create --title "Feature: Tutorial overlay for new users" --label "enhancement" --body "## Summary
Add an interactive tutorial overlay to guide new users through the app features.

## Feature Description
- First-time user onboarding
- Interactive feature highlights
- Step-by-step feature walkthrough
- Skip and replay options
- Progress indicators
- Context-sensitive help tooltips

## Acceptance Criteria
- [ ] Onboarding flow for new users
- [ ] Feature spotlight overlays
- [ ] Interactive tutorial steps
- [ ] Skip tutorial option
- [ ] Replay tutorial from settings
- [ ] Persist tutorial completion state
- [ ] Context help tooltips

## Technical Considerations
- Use \`tutorial_coach_mark\` or \`showcaseview\` package
- Store tutorial state in SharedPreferences
- Design non-intrusive overlay UI
- Support tutorial on key features only
- A/B test tutorial effectiveness"

# Issue 10: Analytics and Insights
gh issue create --title "Feature: Analytics and insights dashboard" --label "enhancement" --body "## Summary
Provide users with analytics and insights about safety trends in their area.

## Feature Description
- Personal activity statistics
- Area safety trends over time
- Incident category breakdown
- Time-of-day safety patterns
- Community contribution metrics
- Weekly/monthly safety reports

## Acceptance Criteria
- [ ] Personal stats dashboard
- [ ] Area incident trends chart
- [ ] Category breakdown pie chart
- [ ] Time pattern visualization
- [ ] User contribution metrics
- [ ] Exportable reports
- [ ] Comparative week-over-week analysis

## Technical Considerations
- Use \`fl_chart\` for data visualization
- Implement data aggregation on backend
- Cache analytics data locally
- Design clean dashboard UI
- Consider privacy in aggregated data"

# Issue 11: Multi-language Support
gh issue create --title "Feature: Multi-language support (i18n)" --label "enhancement" --body "## Summary
Add support for multiple languages to make the app accessible to more users.

## Feature Description
- Support for multiple languages
- In-app language switcher
- Automatic language detection
- Localized date/time formats
- RTL language support
- Dynamic string loading

## Initial Languages
- English (default)
- Spanish
- French
- German
- Portuguese
- Arabic (RTL)

## Acceptance Criteria
- [ ] ARB files for each language
- [ ] Language selection in settings
- [ ] System language detection
- [ ] All UI strings internationalized
- [ ] Date/time/number formatting
- [ ] RTL layout support
- [ ] Fallback to English for missing translations

## Technical Considerations
- Use Flutter's \`intl\` package (already in pubspec)
- Use \`l10n.yaml\` configuration (already exists)
- Implement lazy loading for translations
- Consider crowdsourced translations
- Test RTL layout thoroughly"

# Issue 12: Dark Mode Themes
gh issue create --title "Feature: Dark mode themes" --label "enhancement" --body "## Summary
Add dark mode theme support for comfortable nighttime use and battery savings.

## Feature Description
- Dark theme for entire app
- System theme detection
- Manual theme toggle in settings
- Smooth theme transitions
- Map dark mode tiles
- Consistent color palette

## Acceptance Criteria
- [ ] Dark theme color palette
- [ ] Theme toggle in settings
- [ ] System theme detection
- [ ] All screens support dark mode
- [ ] Dark map tiles integration
- [ ] Theme persistence
- [ ] Smooth transition animations

## Technical Considerations
- Use Flutter's \`ThemeData\` with dark variant
- Store preference in SharedPreferences
- Consider OLED-optimized true black theme
- Test all components in dark mode
- Update shadcn_ui theming for dark mode"
```

---

## Quick Create Script

Save this as `create_issues.sh` and run it:

```bash
#!/bin/bash

# Make sure you're logged in: gh auth login

REPO="asare-21/safezone"

echo "Creating 12 planned feature issues..."

# Create each issue
gh issue create -R $REPO --title "Feature: Media upload for incident reports (camera/gallery)" --label "enhancement" --body-file /dev/stdin <<'EOF'
## Summary
Add the ability for users to attach photos or videos when reporting incidents.

## Feature Description
- Allow users to capture photos using the device camera
- Allow users to select images from their gallery
- Support for multiple image uploads per incident
- Image compression and optimization for network transfer
- Preview images before submitting the report
- Store media files securely with proper encryption

## Acceptance Criteria
- [ ] Camera integration with permission handling
- [ ] Gallery picker implementation
- [ ] Image compression before upload
- [ ] Image preview in incident report form
- [ ] Backend API for media upload
- [ ] Media display in incident details view
- [ ] Proper error handling for failed uploads
EOF

gh issue create -R $REPO --title "Feature: Push notifications for incident proximity" --label "enhancement" --body-file /dev/stdin <<'EOF'
## Summary
Send push notifications to users when they are approaching areas with recent safety incidents.

## Feature Description
- Real-time proximity detection using device location
- Configurable alert radius (0.5km - 10km)
- Category-based notification filtering
- Smart notification throttling to prevent spam
- Background location monitoring
- Rich notifications with incident details

## Acceptance Criteria
- [ ] Background location service implementation
- [ ] Geofencing for incident areas
- [ ] FCM push notification integration
- [ ] User preferences for notification types
- [ ] Notification throttling logic
- [ ] Rich notification with action buttons
- [ ] Battery optimization considerations
EOF

gh issue create -R $REPO --title "Feature: Route safety scoring" --label "enhancement" --body-file /dev/stdin <<'EOF'
## Summary
Provide safety scores for walking/driving routes based on incident data along the path.

## Feature Description
- Calculate safety score based on incidents along route
- Display color-coded route segments (safe/moderate/caution)
- Suggest alternative safer routes
- Time-of-day safety adjustments
- Historical incident analysis for routes
- Integration with navigation apps

## Acceptance Criteria
- [ ] Route drawing on map
- [ ] Safety score calculation algorithm
- [ ] Visual route segment coloring
- [ ] Alternative route suggestions
- [ ] Time-based safety adjustments
- [ ] Route safety summary display
- [ ] Share route safety report
EOF

gh issue create -R $REPO --title "Feature: Offline incident caching" --label "enhancement" --body-file /dev/stdin <<'EOF'
## Summary
Enable the app to work offline by caching incident data locally.

## Feature Description
- Cache incidents for offline viewing
- Queue incident reports when offline
- Automatic sync when connection restored
- Local database for incident storage
- Cache invalidation strategy
- Offline map tile support

## Acceptance Criteria
- [ ] Local database implementation (SQLite/Hive)
- [ ] Incident data caching on load
- [ ] Offline incident report queue
- [ ] Network connectivity monitoring
- [ ] Background sync service
- [ ] Cache size management
- [ ] Conflict resolution for synced data
EOF

gh issue create -R $REPO --title "Feature: Admin moderation dashboard" --label "enhancement" --body-file /dev/stdin <<'EOF'
## Summary
Create an admin dashboard for moderating reported incidents and managing users.

## Feature Description
- Review and approve/reject incidents
- User management (ban, warn, elevate)
- Incident statistics and reports
- False report detection tools
- Bulk moderation actions
- Audit logging

## Acceptance Criteria
- [ ] Admin authentication and authorization
- [ ] Incident review queue
- [ ] Approve/reject/flag actions
- [ ] User management panel
- [ ] Moderation statistics
- [ ] Activity audit log
- [ ] Bulk action support
EOF

gh issue create -R $REPO --title "Feature: Heatmap visualization" --label "enhancement" --body-file /dev/stdin <<'EOF'
## Summary
Display incident density as a heatmap overlay on the map.

## Feature Description
- Color-coded heat map based on incident density
- Adjustable intensity and radius
- Time-range filtering for heatmap
- Category-specific heatmaps
- Toggle between markers and heatmap view
- Legend for heatmap colors

## Acceptance Criteria
- [ ] Heatmap layer implementation
- [ ] Intensity calculation based on incidents
- [ ] Time filter integration
- [ ] Category filter integration
- [ ] Toggle control for heatmap view
- [ ] Color legend display
- [ ] Performance optimization for large datasets
EOF

gh issue create -R $REPO --title "Feature: Marker clustering for incidents" --label "enhancement" --body-file /dev/stdin <<'EOF'
## Summary
Cluster nearby incident markers at lower zoom levels for better map performance and readability.

## Feature Description
- Automatic clustering of nearby markers
- Cluster count display
- Expand clusters on tap or zoom
- Smooth animation for cluster transitions
- Customizable cluster appearance
- Spiderfying for overlapping markers

## Acceptance Criteria
- [ ] Marker clustering implementation
- [ ] Cluster count badges
- [ ] Tap to expand cluster
- [ ] Zoom-based clustering
- [ ] Smooth cluster animations
- [ ] Spiderfy for dense areas
- [ ] Performance testing with 1000+ markers
EOF

gh issue create -R $REPO --title "Feature: Pull-to-refresh for data refresh" --label "enhancement" --body-file /dev/stdin <<'EOF'
## Summary
Implement pull-to-refresh gesture for refreshing incident data in lists and map view.

## Feature Description
- Pull-to-refresh on alerts list
- Pull-to-refresh on incident history
- Map refresh gesture or button
- Visual loading indicator
- Last updated timestamp display
- Haptic feedback on refresh

## Acceptance Criteria
- [ ] RefreshIndicator on alerts screen
- [ ] RefreshIndicator on incident history
- [ ] Map refresh button
- [ ] Loading state during refresh
- [ ] Last updated timestamp
- [ ] Error handling for failed refresh
- [ ] Haptic feedback implementation
EOF

gh issue create -R $REPO --title "Feature: Tutorial overlay for new users" --label "enhancement" --body-file /dev/stdin <<'EOF'
## Summary
Add an interactive tutorial overlay to guide new users through the app features.

## Feature Description
- First-time user onboarding
- Interactive feature highlights
- Step-by-step feature walkthrough
- Skip and replay options
- Progress indicators
- Context-sensitive help tooltips

## Acceptance Criteria
- [ ] Onboarding flow for new users
- [ ] Feature spotlight overlays
- [ ] Interactive tutorial steps
- [ ] Skip tutorial option
- [ ] Replay tutorial from settings
- [ ] Persist tutorial completion state
- [ ] Context help tooltips
EOF

gh issue create -R $REPO --title "Feature: Analytics and insights dashboard" --label "enhancement" --body-file /dev/stdin <<'EOF'
## Summary
Provide users with analytics and insights about safety trends in their area.

## Feature Description
- Personal activity statistics
- Area safety trends over time
- Incident category breakdown
- Time-of-day safety patterns
- Community contribution metrics
- Weekly/monthly safety reports

## Acceptance Criteria
- [ ] Personal stats dashboard
- [ ] Area incident trends chart
- [ ] Category breakdown pie chart
- [ ] Time pattern visualization
- [ ] User contribution metrics
- [ ] Exportable reports
- [ ] Comparative week-over-week analysis
EOF

gh issue create -R $REPO --title "Feature: Multi-language support (i18n)" --label "enhancement" --body-file /dev/stdin <<'EOF'
## Summary
Add support for multiple languages to make the app accessible to more users.

## Feature Description
- Support for multiple languages
- In-app language switcher
- Automatic language detection
- Localized date/time formats
- RTL language support
- Dynamic string loading

## Initial Languages
- English (default)
- Spanish
- French
- German
- Portuguese
- Arabic (RTL)

## Acceptance Criteria
- [ ] ARB files for each language
- [ ] Language selection in settings
- [ ] System language detection
- [ ] All UI strings internationalized
- [ ] Date/time/number formatting
- [ ] RTL layout support
- [ ] Fallback to English for missing translations
EOF

gh issue create -R $REPO --title "Feature: Dark mode themes" --label "enhancement" --body-file /dev/stdin <<'EOF'
## Summary
Add dark mode theme support for comfortable nighttime use and battery savings.

## Feature Description
- Dark theme for entire app
- System theme detection
- Manual theme toggle in settings
- Smooth theme transitions
- Map dark mode tiles
- Consistent color palette

## Acceptance Criteria
- [ ] Dark theme color palette
- [ ] Theme toggle in settings
- [ ] System theme detection
- [ ] All screens support dark mode
- [ ] Dark map tiles integration
- [ ] Theme persistence
- [ ] Smooth transition animations
EOF

echo "Done! Created 12 feature issues."
```

Make it executable and run:
```bash
chmod +x create_issues.sh
./create_issues.sh
```
