# Project Progress Log

## Completed Actions

### Phase 1: Setup & Scripts
- **Script Migration:** Moved `moodle_fetch.py` to `scripts/` directory.
- **Security Improvement:** Modified `moodle_fetch.py` to load `MOODLE_TOKEN` and `MOODLE_URL` from environment variables using `python-dotenv` and `os.environ`, removing hardcoded credentials.
- **Documentation:** Added instructions for setting up `.env` file.
- **Android Environment:** Installed OpenJDK 17, unzip, and the full Android SDK Command-line Tools and Platform Tools (API 34 & 36). Accepted all licenses.
- **Flutter Initialization:** Initialized a new Flutter project (`flutter create .`) with Android, iOS, and Web support. Removed desktop platforms.
- **Git Configuration:** Created a comprehensive `.gitignore` and committed the initial project structure.

### Phase 2: Dependency Management
- **Flutter Package Installation:** Added `http`, `flutter_secure_storage`, `home_widget`, `workmanager`, and `flutter_dotenv` packages.
- **Environment Configuration:** Created `.env` file and configured `pubspec.yaml` to include it as an asset.

### Phase 3: "Hello World" Validation
- **Application Entry Point:** Sanitized `lib/main.dart` to a minimal `MaterialApp` to prepare for UI development.
- **Emulator Test:** Successfully ran the application on an Android Emulator to confirm the build pipeline is functional.

### Phase 4: Core Logic Implementation
- **Data Model:** Created `lib/models/moodle_event.dart` with a `fromJson` factory to parse Moodle API responses.
- **API Client:** Implemented `lib/services/moodle_client.dart` to fetch calendar events using the `core_calendar_get_action_events_by_timesort` webservice function.
- **UI Integration:** Integrated the `MoodleClient` into the main UI using a `FutureBuilder` to asynchronously fetch and display the list of deadlines.
- **Date Formatting:** Added the `intl` package to format the Unix timestamps from the API into a human-readable date and time string.

### Phase 5: UI Development & Polish
- **Priority-Based Design:** Implemented color-coded event cards with pastel colors (pastel red #EF5350 for today, pastel yellow #FFCA28 for tomorrow, pastel light blue #64B5F6 for future).
- **Date Categorization:** Created `EventDateUtils` to group events into time-based categories (Today, Tomorrow, This Week, etc.).
- **Hebrew Localization:** Centralized all strings in `app_strings.dart` with Hebrew translations.
- **Time-Based Greetings:** Implemented dynamic greeting header that changes based on time of day.
- **Component Architecture:** Built reusable widgets including `EventCard`, `EventSection`, `GreetingHeader`, and `SummaryText`.

### Phase 6: Data Refresh & Loading States
- **Shimmer Package:** Added `shimmer: ^3.0.0` dependency for skeleton loading animations.
- **State Management Refactor:** Migrated from `FutureBuilder` to manual state management with `_isLoading`, `_events`, and `_errorMessage` state variables.
- **Pull-to-Refresh:** Implemented `RefreshIndicator` with `_onRefresh()` method for manual data refresh via swipe-down gesture.
- **Shimmer Loading View:** Created `ShimmerLoadingView` widget displaying skeleton cards during initial data load.
- **Error Handling:** Implemented `ErrorStateView` widget with retry button for failed requests.
- **Error Differentiation:** Separate error handling for initial load (full-screen error) vs refresh errors (SnackBar with retry).
- **Hebrew Error Messages:** Added localized error strings (`loadError`, `refreshError`, `retryButton`).

### Phase 7: Code Refactoring
- **Widget Extraction:** Refactored `home_screen.dart` by extracting loading and error states into dedicated widgets.
- **Shimmer Event Card:** Created reusable `ShimmerEventCard` widget matching real card layout.
- **Code Reduction:** Reduced `home_screen.dart` from 283 lines to 179 lines (37% reduction).
- **Improved Maintainability:** Better separation of concerns with presentation logic moved to dedicated widget files.

### Phase 8: Android Widget Integration
- **Widget Layouts:** Created `widget_layout.xml` with RTL support and `widget_event_item.xml` for displaying individual events.
- **Widget Resources:** Added `widget_background.xml` drawable, Hebrew string resources, and `widget_info.xml` configuration.
- **Widget Service:** Implemented `lib/services/widget_service.dart` with data bridge using `home_widget` package to save event data to shared preferences.
- **Background Sync:** Integrated `workmanager` for periodic widget updates every 30 minutes with network constraints.
- **Kotlin Widget Provider:** Created `MoodleWidgetProvider.kt` that dynamically renders events with:
  - Priority color indicators (pastel red #EF5350 for today, pastel yellow #FFCA28 for tomorrow, pastel light blue #64B5F6 for future)
  - Hebrew month abbreviations
  - Empty state with checkmark icon when no deadlines exist
  - Refresh button functionality
- **Android Configuration:** Updated `AndroidManifest.xml` with widget receiver, WorkManager services, and required permissions.
- **App Integration:** Modified `main.dart` to initialize widget service on app start, and `home_screen.dart` to update widget after loading/refreshing events.

---
*This file tracks the history of completed actions. For pending tasks, see `docs/checklist.md`.*
