# Initial Plan

## Phase 1: Project & Environment Initialization

### Create Project Structure
*   Create a root folder named `moodle-monitor`.
*   Inside, create a `scripts/` directory.
*   Move your existing Python script (`moodle_fetch.py`) into `scripts/`.
*   Modify the script to read the token from an environment variable (`os.environ.get('MOODLE_TOKEN')`) instead of hardcoding it.

### Initialize Flutter
*   Open terminal in the root `moodle_monitor` folder.
*   Run `flutter create .` (scaffolds Flutter structure alongside your scripts).

### Git Setup
*   Run `git init`.
*   Create a `.gitignore` file and append:
    ```plaintext
    .env
    *.key
    /build
    .DS_Store
    ```
*   Commit the initial project structure (excluding secrets).

## Phase 2: Dependency Management

### Install Packages
*   Run the following command to add core libraries:
    ```bash
    flutter pub add http flutter_secure_storage home_widget workmanager flutter_dotenv
    ```

### Security Configuration
*   Create a `.env` file in the root directory:
    ```plaintext
    MOODLE_TOKEN=your_actual_token_here
    ```
*   Open `pubspec.yaml` and register the assets so Flutter can see the file:
    ```yaml
    assets:
      - .env
    ```

## Phase 3: The "Hello World" Validation

### Sanitize Entry Point
*   Delete the contents of `lib/main.dart`.
*   Create a minimal `MaterialApp` that displays "Moodle Monitor" in the center of the screen.

### Test Run (Android)
*   Launch your Android Emulator (via Android Studio or AVD Manager).
*   Run `flutter run`.
*   **Goal:** Confirm the app installs, opens, and displays text without crashing.

## Phase 4: Core Logic Implementation (Dart)

### Data Model
*   Create `lib/models/moodle_event.dart`.
*   Implement the class with `fromJson` to parse `name`, `course.fullname`, and `timesort` (Unix timestamp).

### API Client
*   Create `lib/services/moodle_client.dart`.
*   Implement the `fetchDeadlines()` method using the `http` package and the `core_calendar_get_action_events_by_timesort` endpoint.
*   Use `flutter_dotenv` to inject the token at runtime.

### UI Integration
*   Build a simple `ListView` in `main.dart` that uses a `FutureBuilder` to display the data fetched from `MoodleClient`.

## Phase 5: Android Widget Integration

### Widget Layout (Native)
*   Create `android/app/src/main/res/layout/widget_layout.xml`.
*   Define the XML UI (`TextView`s for the tasks).

### Data Bridge
*   In Dart: Implement `HomeWidget.saveWidgetData` to save the fetched JSON to shared storage.

*   In Kotlin (`android/.../MainActivity.kt`): Implement the `HomeWidgetProvider` to read that data and update the XML layout.

### Background Sync
*   Configure `workmanager` to run a headless task every 15 minutes to fetch new data and update the widget while the app is closed.

## Future Steps: iOS Widget (Windows Workaround)

Since you cannot build this locally, this is the "Blind Deploy" workflow for the future:

*   **Code the UI:** Write the Dart logic; it remains identical.
*   **Repo Setup:** Push your code to a private GitHub repository.
*   **CI/CD Pipeline:** Connect the repo to Codemagic (they offer a free tier with macOS machines).
*   **Build Config:** Configure Codemagic to build `ios/Runner.xcworkspace` and generate an unsigned `.ipa` (or signed if you have a developer account).
*   **Sideload:** Download the `.ipa` to your PC and install it on your iPhone using AltStore.

**Note:** You won't be able to edit the native iOS widget UI (SwiftUI) easily this way. You will likely stick to a very basic default layout or ask a friend with a Mac to compile the initial widget layout for you.