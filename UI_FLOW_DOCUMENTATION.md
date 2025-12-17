# Custom Map Markers - UI/UX Flow

## User Interface Flow

### 1. Map Screen with User Location Markers

```
┌─────────────────────────────────────────────────────────┐
│  [Search Bar]                                           │
│  [24h] [7d] [30d]  ← Time filters                      │
│  [Theft] [Assault] [Suspicious] [Lighting] ← Filters   │
│                                                         │
│          🗺️ Map View                                    │
│                                                         │
│      🔴 ← Incident Marker (Red circle with icon)       │
│                                                         │
│      👤 ← Other User (40px circle, white border)        │
│                                                         │
│      👤 ← Current User (40px circle, BLUE border)       │
│     "You"  ← Label                                      │
│                                                         │
│      🟡 ← Incident Marker (Yellow circle with icon)     │
│                                                         │
│      👤 ← Other User                                    │
│                                                         │
│                                                         │
│        ┌─────────────────────────┐                     │
│        │   📍 Report Incident    │  ← Button           │
│        └─────────────────────────┘                     │
│                                                         │
│  [🎯] ← FAB (Center on user location)                  │
└─────────────────────────────────────────────────────────┘
```

### 2. Icon Selection Dialog (Tap Current User Marker)

```
┌─────────────────────────────────────────┐
│  👤  Choose Your Icon                   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │                                 │   │
│  │   🐾         📦         🎨      │   │ ← Grid of icons
│  │  Animal    Courier   Donatello  │   │   (3 columns)
│  │   (●)                           │   │   Selected has
│  │                                 │   │   blue border
│  │   🍕         🐧                 │   │
│  │   Food     Penguin              │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│                         [Close]         │
└─────────────────────────────────────────┘
```

### 3. After Icon Selection

```
┌─────────────────────────────────────────┐
│                                         │
│  Map updates immediately ✨              │
│                                         │
│      🍕  ← Current User (new icon)      │
│     "You"                               │
│                                         │
│  ╔═════════════════════════════════╗   │
│  ║ ✓ Icon updated successfully    ║   │ ← Snackbar
│  ╚═════════════════════════════════╝   │   notification
│                                         │
└─────────────────────────────────────────┘
```

## Component Breakdown

### User Location Marker Component

```dart
Marker(
  point: userLocation.location,
  width: 50,    // Container width (includes label)
  height: 50,   // Container height
  child: Column(
    children: [
      Container(
        width: 40,   // ← Uniform icon size
        height: 40,  // ← Uniform icon size
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isCurrentUser ? primary : white,
            width: isCurrentUser ? 3 : 2,  // ← Different borders
          ),
        ),
        child: ClipOval(
          child: Image.asset(iconPath),  // ← Custom fun icon
        ),
      ),
      if (isCurrentUser)
        Container(
          child: Text('You'),  // ← Label for current user
        ),
    ],
  ),
)
```

## Icon Characteristics

### Size Specifications
- **Source Icons**: 128x128 pixels (high quality)
- **Display Size**: 40x40 pixels (uniform on map)
- **Border Width**: 2-3 pixels (visual distinction)
- **Container**: 50x50 pixels (including label space)

### Visual Hierarchy
1. **Current User** (Most prominent)
   - Primary color border (3px)
   - "You" label
   - Tap-enabled for icon change

2. **Other Users** (Secondary)
   - White border (2px)
   - No label
   - Visual presence without distraction

3. **Incident Markers** (Background)
   - Category-colored circles
   - Icon indicators
   - Layered below user markers

## Interaction Flow

```
User taps current marker
        ↓
Dialog opens with icon grid
        ↓
User taps desired icon
        ↓
Icon selection confirmed
        ↓
Dialog closes
        ↓
Map updates with new icon
        ↓
Success notification shown
        ↓
User continues using map
```

## State Management

```
_userLocations (List<UserLocation>)
        ↓
   Contains user data
        ↓
_currentUserIcon (String)
        ↓
   Current user's icon path
        ↓
FunIconLoader (Singleton)
        ↓
   Manages available icons
   Caches user assignments
```

## Icon Selection State

```
Initial State:
  Current User → iconForUser('currentUser')
  Other Users → iconForUser('userId')

After Selection:
  Current User → selectedIconPath
  Cache updated → consistent across sessions
```

## Error Handling

```
Icon Load Error
      ↓
Error Builder Triggered
      ↓
Fallback Icon Shown
      ↓
Grey container + Person icon
      ↓
User experience preserved
```

## Performance Optimizations

1. **Preloading**
   ```
   initState()
     ↓
   validateAssets()
     ↓
   preload(context)
     ↓
   Icons ready for instant display
   ```

2. **Caching**
   ```
   First request for userId
     ↓
   Calculate hash
     ↓
   Store in cache
     ↓
   Subsequent requests: O(1) lookup
   ```

3. **Deterministic Assignment**
   ```
   userId.hashCode
     ↓
   % iconCount
     ↓
   Consistent icon per user
   ```

## Accessibility

- **Visual**: Clear borders and sizing
- **Interaction**: Large tap targets (40x40 minimum)
- **Feedback**: Immediate visual updates
- **Notifications**: Success confirmations
- **Error Handling**: Graceful fallbacks

## Design Patterns Used

1. **Singleton Pattern** - FunIconLoader
2. **Factory Pattern** - Icon creation
3. **Builder Pattern** - UI construction
4. **Observer Pattern** - State management
5. **Strategy Pattern** - Icon assignment

## Future UI Enhancements

1. **Animations**
   - Icon change transitions
   - Marker pulse effects
   - Selection highlights

2. **Categories**
   - Tabbed icon selection
   - Themed icon sets
   - Seasonal icons

3. **Customization**
   - Color overlays
   - Icon borders
   - Badge overlays

4. **Social Features**
   - Share icon choice
   - Friend icon visibility
   - Group icons

This UI flow ensures a smooth, intuitive user experience for customizing map markers while maintaining visual consistency and performance.
