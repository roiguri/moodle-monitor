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

---
*This file tracks the history of completed actions. For pending tasks, see `docs/checklist.md`.*