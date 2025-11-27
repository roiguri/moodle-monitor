# Android Widget Setup Guide

## Overview
The Moodle Monitor Android widget displays your upcoming deadlines directly on your home screen with a clean, RTL (right-to-left) Hebrew interface.

## Features
- **Priority Color Coding:** Events are marked with colored indicators:
  - 🔴 Pastel Red (`#EF5350`) - Deadlines today
  - 🟡 Pastel Yellow (`#FFCA28`) - Deadlines tomorrow
  - 🔵 Pastel Light Blue (`#64B5F6`) - Future deadlines
- **Hebrew Localization:** All text displayed in Hebrew with RTL layout
- **Empty State:** Shows a friendly "All clear!" message when no deadlines exist
- **Auto-Refresh:** Updates every 30 minutes in the background via WorkManager
- **Manual Refresh:** Tap the refresh icon to sync immediately

## Installation & Testing

### 1. Build and Run the App
```bash
flutter build apk --debug
flutter run
```

### 2. Add Widget to Home Screen
1. Long-press on your Android home screen
2. Tap "Widgets"
3. Find "Moodle Monitor Widget"
4. Drag and drop onto home screen
5. Resize as needed

### 3. Verify Widget Functionality
- Open the Moodle Monitor app to fetch initial data
- Pull to refresh in the app
- Check that widget updates with the latest deadlines
- Verify colors match priority (red for today, yellow for tomorrow, blue for future)
- Test empty state by clearing all deadlines

## Technical Architecture

### Data Flow
```
App Launch → WidgetService.initialize() → WorkManager setup
User Refresh → MoodleClient.fetchDeadlines() → WidgetService.updateWidget()
Background → WorkManager (every 30 min) → WidgetService.updateWidget()
Widget Display → MoodleWidgetProvider reads SharedPreferences → Render UI
```

### Files Created

**Dart (Flutter):**
- `lib/services/widget_service.dart` - Widget data management and WorkManager setup
- Updated `lib/main.dart` - Widget service initialization
- Updated `lib/screens/home_screen.dart` - Trigger widget updates on data changes

**Kotlin (Native Android):**
- `android/app/src/main/kotlin/com/example/moodle_monitor/MoodleWidgetProvider.kt` - Widget rendering logic

**XML (Android Resources):**
- `android/app/src/main/res/layout/widget_layout.xml` - Main widget layout
- `android/app/src/main/res/layout/widget_event_item.xml` - Event item template
- `android/app/src/main/res/drawable/widget_background.xml` - Widget background style
- `android/app/src/main/res/xml/widget_info.xml` - Widget metadata configuration
- `android/app/src/main/res/values/strings.xml` - Hebrew strings
- `android/app/src/main/res/values/bools.xml` - WorkManager configuration

**Android Configuration:**
- Updated `android/app/src/main/AndroidManifest.xml` - Widget receiver and permissions

## Troubleshooting

### Widget Not Updating
1. Check that the app has internet permissions
2. Verify `.env` file has correct `MOODLE_TOKEN` and `MOODLE_URL`
3. Open the app and pull to refresh manually
4. Check logcat for errors: `adb logcat | grep MoodleWidget`

### Colors Not Matching
Ensure the Kotlin color codes match:
- High priority: `#EF5350` (Pastel Red)
- Medium priority: `#FFCA28` (Pastel Yellow)
- Low priority: `#64B5F6` (Pastel Light Blue)

### Empty State Always Showing
- Verify SharedPreferences are being written: Check `is_empty` and `event_count` keys
- Ensure `WidgetService.updateWidget()` is being called after fetching events

### RTL Layout Issues
- Confirm `android:layoutDirection="rtl"` is set in widget layouts
- Check that Hebrew strings are properly defined in `strings.xml`

## Background Sync Configuration

WorkManager is configured to update the widget every 30 minutes when:
- Device has network connectivity
- App is installed (doesn't need to be running)

To change update frequency, modify `widget_service.dart`:
```dart
frequency: const Duration(minutes: 30), // Change this value
```

## Widget Customization

### Adjusting Widget Size
Edit `android/app/src/main/res/xml/widget_info.xml`:
```xml
android:minWidth="250dp"    <!-- Minimum width -->
android:minHeight="180dp"   <!-- Minimum height -->
android:targetCellWidth="4" <!-- Grid cells wide -->
android:targetCellHeight="3" <!-- Grid cells tall -->
```

### Changing Colors
Update priority colors in `MoodleWidgetProvider.kt`:
```kotlin
val priorityColor = when (eventPriority) {
    "high" -> Color.parseColor("#YOUR_COLOR")
    "medium" -> Color.parseColor("#YOUR_COLOR")
    else -> Color.parseColor("#YOUR_COLOR")
}
```

### Modifying Update Interval
Edit `WidgetService._registerBackgroundTask()`:
```dart
frequency: const Duration(minutes: YOUR_INTERVAL),
```

## Next Steps
- Test widget on physical device
- Verify background updates work correctly
- Check battery optimization doesn't kill WorkManager
- Test widget behavior with various deadline counts (0, 1, 5+)
- Verify RTL layout on different Android versions
