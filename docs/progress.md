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

---
*This file tracks the history of completed actions. For pending tasks, see `docs/checklist.md`.*
