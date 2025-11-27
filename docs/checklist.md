# Project Checklist

## Phase 1: Project & Environment Initialization
- [x] Create project structure and `scripts` folder.
- [x] Move `moodle_fetch.py` to `scripts/`.
- [x] Modify `moodle_fetch.py` to use `MOODLE_TOKEN` env var.
- [x] Initialize Flutter project (`flutter create .`).
- [x] Configure Git (gitignore, initial commit).

## Phase 2: Dependency Management
- [x] Install Flutter packages (`http`, `flutter_secure_storage`, `home_widget`, `workmanager`, `flutter_dotenv`).
- [x] Create `.env` file and configure `pubspec.yaml` assets.

## Phase 3: "Hello World" Validation
- [x] Sanitize `lib/main.dart` (minimal MaterialApp).
- [x] Run `flutter run` on Android Emulator.

## Phase 4: Core Logic Implementation
- [x] Create `lib/models/moodle_event.dart`.
- [x] Create `lib/services/moodle_client.dart` (API Client).
- [x] Implement `fetchDeadlines()`.
- [x] Integrate UI with `FutureBuilder` in `main.dart`.

## Phase 5: UI Development & Polish
- [x] Implement priority-based color scheme.
- [x] Create date categorization logic (`EventDateUtils`).
- [x] Build reusable widget components.
- [x] Add Hebrew localization support.
- [x] Implement time-based greeting system.

## Phase 6: Data Refresh & Loading States
- [x] Add shimmer package dependency.
- [x] Refactor state management (from FutureBuilder to manual state).
- [x] Implement pull-to-refresh functionality.
- [x] Create shimmer loading skeleton views.
- [x] Implement error handling with retry.
- [x] Add Hebrew error messages.

## Phase 7: Code Refactoring
- [x] Extract shimmer loading view into separate widget.
- [x] Extract error state view into separate widget.
- [x] Create reusable shimmer event card widget.
- [x] Refactor `home_screen.dart` for better maintainability.

## Phase 8: Android Widget Integration
- [x] Create native layout `widget_layout.xml`.
- [x] Create widget event item layout `widget_event_item.xml`.
- [x] Create widget background drawable and resources.
- [x] Add Hebrew string resources for widget.
- [x] Create widget info configuration (`widget_info.xml`).
- [x] Implement Data Bridge in Dart (`WidgetService`).
- [x] Implement Kotlin `MoodleWidgetProvider`.
- [x] Configure `workmanager` for background sync.
- [x] Update AndroidManifest.xml with widget and WorkManager configuration.
- [x] Integrate widget updates in HomeScreen (on load and refresh).
- [ ] Test widget on Android device/emulator.
