# Moodle Monitor - Upgrade V2 Tracker

This document tracks the progress of the Moodle Monitor application upgrade to V2.

**Branch**: `feat/app-upgrade-v2`

**Last Updated**: 2025-11-29

---

## Phase 1: Navigation & Architecture Restructuring

**Goal**: Establish the new navigation structure and refactor the existing home screen.

### Tasks:
- [x] Request design plans for navigation bar
- [x] Create TasksView: Refactor the existing HomeScreen content (deadlines list, greeting) into a new widget `lib/screens/tasks_view.dart`. Remove the Scaffold from this widget so it can be embedded.
- [x] Create CoursesView & SettingsView: Create placeholder widgets for these two new screens.
- [x] Implement MainScreen: Create `lib/screens/main_screen.dart`.
  - [x] Implement a Scaffold with a BottomNavigationBar (or the custom App Bar from the design).
  - [x] Set up state (`_selectedIndex`) to switch between the three views.
- [x] Update Entry Point: Modify `lib/main.dart` to point to MainScreen instead of HomeScreen.

---

## Phase 2: Dynamic Configuration (Settings & Persistence)

**Goal**: Allow users to configure the app without editing code/env files.

### Tasks:
- [ ] Add Dependencies: Add `shared_preferences` (for UI settings) and ensure `flutter_secure_storage` is configured (for the token) in `pubspec.yaml`.
- [ ] Create Settings UI: Implement `lib/screens/settings_view.dart` with:
  - [ ] TextField for Moodle URL.
  - [ ] TextField for Moodle Token.
  - [ ] "Save" button to persist these credentials to Secure Storage.
  - [ ] Input validation (check for empty fields).
- [ ] Refactor MoodleClient: Modify `lib/services/moodle_client.dart`:
  - [ ] Remove strict dependency on dotenv.
  - [ ] Update fetchDeadlines to read Token/URL from flutter_secure_storage.
  - [ ] Throw a specific "AuthError" if credentials are missing.
- [ ] Handle Auth State: Update main.dart or MainScreen to check for credentials on launch. Redirect to SettingsView (or show a setup prompt) if the token is missing.

---

## Phase 3: Course Management

**Goal**: View all courses, hide specific ones, and link to Moodle.

### Tasks:
- [ ] Request documentation on get courses API call
- [ ] Add URL Launcher: Add `url_launcher` to `pubspec.yaml` (already present).
- [ ] Update Course Model: Ensure your "get all courses" method maps to a model containing: id, fullname, shortname, and viewUrl.
- [ ] Implement Persistence for Hidden Courses:
  - [ ] Create a service (e.g., `PreferencesService`) to save/retrieve a `List<String>` of hidden course IDs using `shared_preferences`.
- [ ] Build CoursesView UI:
  - [ ] Display a list of all courses fetched from the API.
  - [ ] Add a "Visibility" toggle icon for each course.
  - [ ] Action: Tapping the course card should launch the viewUrl in a browser.
  - [ ] Action: Tapping the toggle should add/remove the ID from the hidden list.
- [ ] Filter Tasks: Update the TasksView logic to exclude assignments belonging to hidden course IDs.

---

## Phase 4: Theming (Dark/Light Mode)

**Goal**: Implement a theme switcher and polish the UI.

### Tasks:
- [ ] Define Themes: Update `lib/constants/app_colors.dart` to include a Dark Mode palette. Define ThemeData for both light and dark modes in `lib/main.dart`.
- [ ] State Management: Lift the ThemeMode state to main.dart (or use a ValueNotifier/ChangeNotifier).
- [ ] Settings Toggle: Add a SwitchListTile in SettingsView to toggle between Light/Dark/System modes.
- [ ] Apply Styling: Ensure all cards, text, and backgrounds in TasksView and CoursesView respond correctly to the active theme.

---

## Notes

- All changes are being made on branch `feat/app-upgrade-v2`
- Commits should be small and atomic with descriptive messages
- Stop and request approval after each major step or sub-phase
- Ask clarification questions for ambiguous design choices
