# Visual Changes - Incident Reporting System

## New Screen: Report Incident Screen

### Layout
The Report Incident Screen is a full-screen form that provides an intuitive interface for reporting safety incidents.

### Components (Top to Bottom)

#### 1. App Bar
- **Close Button** (top-left): Icon button with 'X' to dismiss the screen
- **Title**: "Report Incident" - centered, bold text
- **Background**: White with no elevation for clean look

#### 2. Info Banner (Below App Bar)
- **Background**: Light blue (primary color with 10% opacity)
- **Icon**: Info outline icon in primary color
- **Text**: "Your report helps keep the community safe"
- **Purpose**: Encourages users and explains the value of reporting

#### 3. Incident Type Section
- **Label**: "Incident Type" - bold, 16px
- **Categories** (Wrap layout):
  - Theft (Red) - Error icon
  - Assault (Orange) - Hand icon
  - Harassment (Red-orange) - Warning icon
  - Accident (Red) - Car crash icon
  - Suspicious (Yellow) - Eye icon
  - Lighting (Purple) - Lightbulb icon
- **Interaction**: 
  - Unselected: White background with gray border
  - Selected: Category color background with white text/icon
  - Shadow effect when selected

#### 4. Title Field
- **Label**: "Title" - bold
- **Input**: Single-line text field
- **Placeholder**: "Brief description of the incident"
- **Background**: Light gray (#F5F5F5)
- **Required**: Yes (shows error if empty)
- **Validation**: "Please enter a title"

#### 5. Description Field
- **Label**: "Description (Optional)" - bold
- **Input**: Multi-line text field (4 lines)
- **Placeholder**: "Add more details about what happened..."
- **Background**: Light gray (#F5F5F5)
- **Required**: No

#### 6. Photos Section
- **Label**: "Add Photos (Optional)" - bold
- **Photo Grid**: 3 columns, shows thumbnails of selected photos
- **Remove Button**: Small 'X' button on each photo (top-right corner)
- **Add Button**: Outlined button with camera icon
  - Text: "Add Photos" (initially) or "Add More Photos" (after adding)
  - Border: Primary color
  - Icon: add_photo_alternate

#### 7. Notify Nearby Section
- **Container**: Gray background (#F5F5F5) with rounded corners
- **Icon**: Bell icon in primary color
- **Title**: "Notify Nearby Users" - bold
- **Description**: "Alert community members in this area"
- **Toggle Switch**: Primary color when on, gray when off
- **Default State**: ON

#### 8. Submit Button (Bottom)
- **Text**: "Submit Report" - white, bold, 16px
- **Background**: Primary color
- **Style**: Full width, rounded corners (12px)
- **States**:
  - Normal: Primary color background
  - Loading: Shows circular progress indicator
  - Disabled: 50% opacity when loading

### Color Scheme
- **Primary Actions**: App primary color
- **Backgrounds**: White (#FFFFFF)
- **Inputs**: Light gray (#F5F5F5)
- **Text**: Black (primary), Gray (secondary)
- **Success**: Green (#34C759)
- **Error**: Red (#FF4C4C)

### Interactions

#### Photo Upload Flow
1. User taps "Add Photos" button
2. Bottom sheet appears with two options:
   - "Take Photo" (camera icon)
   - "Choose from Gallery" (photo library icon)
3. User selects option
4. System camera/gallery opens
5. Photos appear in grid preview
6. User can tap 'X' to remove any photo

#### Form Submission Flow
1. User fills required title field
2. User optionally adds description and photos
3. User configures notification preference
4. User taps "Submit Report"
5. Button shows loading spinner
6. On success:
   - Screen closes
   - Returns to map
   - Success snackbar appears:
     - Green background
     - Check icon
     - Message: "Incident reported and nearby users notified" or "Incident reported successfully"
7. New incident marker appears on map

### Updated Map Screen

#### Report Button
- **Location**: Bottom center of map (above bottom nav)
- **Style**: Elevated button with shadow
- **Icon**: Bullhorn icon
- **Text**: "Report Incident" - white, bold
- **Background**: Primary color
- **Action**: Navigates to Report Incident Screen (full-screen)

#### Success Message
- **Style**: Floating snackbar
- **Background**: Green (#34C759)
- **Icon**: Check circle (white)
- **Text**: Shows notification status
- **Duration**: 3 seconds

### Updated Incident Details Sheet

#### New Photos Section (if incident has photos)
- **Label**: "Photos" - bold
- **Layout**: Horizontal scrolling list
- **Photo Size**: 100x100px
- **Style**: Rounded corners (8px)
- **Placeholder**: If photo not loaded, shows gray background with image icon

## Screen Flow

```
Map Screen
    ↓ (Tap "Report Incident" button)
Report Incident Screen
    ↓ (User fills form and taps "Submit Report")
    ↓ (Loading state)
    ↓ (Success)
Map Screen (with success message and new incident marker)
    ↓ (Tap incident marker)
Incident Details Sheet (shows photos if available)
```

## Responsive Design
- All elements properly padded for different screen sizes
- Form scrollable for smaller screens
- Photo grid adapts to screen width
- Touch targets sized appropriately for mobile

## Accessibility
- All interactive elements have proper labels
- Color contrast meets standards
- Touch targets are at least 48x48dp
- Error messages are clear and helpful
- Form validation provides immediate feedback

## Key Design Decisions

1. **Full-Screen Form**: Provides focused experience without distractions
2. **Visual Categories**: Color-coded categories make selection intuitive
3. **Default Notification ON**: Encourages community awareness by default
4. **Optional Photos**: Reduces friction while allowing evidence documentation
5. **Inline Validation**: Shows errors immediately for better UX
6. **Loading States**: Clear feedback during submission
7. **Success Confirmation**: Clear message about what happened

## Dark Mode Support
- Currently designed for light mode
- Colors use opacity for better adaptation
- Can be extended to support dark mode in future
