# Project Checklist

## Phase 1: Project & Environment Initialization
- [x] Create project structure and `scripts` folder.
- [x] Move `moodle_fetch.py` to `scripts/`.
- [x] Modify `moodle_fetch.py` to use `MOODLE_TOKEN` env var.
- [x] Initialize Flutter project (`flutter create .`).
- [x] Configure Git (gitignore, initial commit).

## Phase 2: Dependency Management
- [ ] Install Flutter packages (`http`, `flutter_secure_storage`, `home_widget`, `workmanager`, `flutter_dotenv`).
- [ ] Create `.env` file and configure `pubspec.yaml` assets.

## Phase 3: "Hello World" Validation
- [ ] Sanitize `lib/main.dart` (minimal MaterialApp).
- [ ] Run `flutter run` on Android Emulator.

## Phase 4: Core Logic Implementation
- [ ] Create `lib/models/moodle_event.dart`.
- [ ] Create `lib/services/moodle_client.dart` (API Client).
- [ ] Implement `fetchDeadlines()`.
- [ ] Integrate UI with `FutureBuilder` in `main.dart`.

## Phase 5: Android Widget Integration
- [ ] Create native layout `widget_layout.xml`.
- [ ] Implement Data Bridge in Dart (`HomeWidget.saveWidgetData`).
- [ ] Implement Kotlin `HomeWidgetProvider`.
- [ ] Configure `workmanager` for background sync.
