# Moodie - Architecture Documentation

## Overview

Moodie is a Flutter-based cross-platform application that provides a modern, priority-based interface for viewing Moodle assignment deadlines. The application follows a feature-based architecture with clear separation of concerns.

## Architecture Principles

### 1. **Separation of Concerns**
- **UI Layer** (`lib/widgets/`, `lib/screens/`): Presentation logic only
- **Business Logic** (`lib/utils/`): Pure Dart logic with no UI dependencies
- **Data Layer** (`lib/models/`, `lib/services/`): Data structures and API communication
- **Configuration** (`lib/constants/`): Centralized styling and strings

### 2. **Component Reusability**
- Widgets are designed to be reusable and configurable
- Styling is consistent via centralized constants
- Components accept parameters for customization

### 3. **Stateless Where Possible**
- Most widgets are stateless to improve performance
- State is only used where necessary (e.g., `HomeScreen` for data fetching)

---

## Directory Structure

```
lib/
├── main.dart                          # Application entry point
├── constants/                         # Configuration & styling
│   ├── app_colors.dart               # Color palette (priority-based)
│   ├── app_strings.dart              # Hebrew strings
│   └── text_styles.dart              # Typography constants
├── models/                            # Data structures
│   └── moodle_event.dart             # Event/deadline model
├── services/                          # External integrations
│   └── moodle_client.dart            # Moodle API client
├── utils/                             # Business logic
│   ├── date_utils.dart               # Date grouping & priority logic
│   ├── event_counter.dart            # Weekly event counting
│   └── greeting_helper.dart          # Time-based greeting logic
├── widgets/                           # Reusable UI components
│   ├── event_card.dart               # Priority-styled event card
│   ├── event_section.dart            # Section with header + events
│   ├── greeting_header.dart          # Time-based greeting display
│   ├── summary_text.dart             # Weekly deadline summary
│   ├── shimmer_event_card.dart       # Skeleton loading card
│   ├── shimmer_loading_view.dart     # Full shimmer loading state
│   └── error_state_view.dart         # Error display with retry
└── screens/                           # Top-level pages
    └── home_screen.dart              # Main application screen
```

---

## Design Guidelines

### Color Scheme

**Priority-Based Pastel Colors:**

| Priority | Use Case | Border Color | Background | Purpose |
|----------|----------|--------------|------------|---------|
| High | Today's events | `#EF5350` (Pastel Red) | `#FFEBEE` | Creates urgency |
| Medium | Tomorrow's events | `#FFCA28` (Pastel Yellow) | `#FFF9E6` | Warning/act soon |
| Low | Future events | `#64B5F6` (Light Blue) | `#E3F2FD` | Calm/planned |

**Defined in:** `lib/constants/app_colors.dart`

### Typography

All text styles are defined in `lib/constants/text_styles.dart`:

- **Heading** (28px, bold): Greeting text
- **Section Header** (18px, bold): Date category headers
- **Card Course** (16px, bold): Event title in cards
- **Card Event** (14px, regular): Course name in cards
- **Card Time** (14px, semi-bold): Deadline time

### Spacing & Layout

**Standard spacing values:**
- Card margin: `EdgeInsets.symmetric(horizontal: 16, vertical: 8)`
- Section padding: `EdgeInsets.fromLTRB(16, 24, 16, 8)`
- Card border width: `4px` (right side for RTL)
- Card border radius: `12px`

---

## Component Guidelines

### 1. Event Cards (`lib/widgets/event_card.dart`)

**Purpose:** Display individual event with priority-based styling

**Props:**
- `event: MoodleEvent` - The event data
- `priority: EventPriority` - Determines color scheme

**Behavior:**
- Border appears on **right side** (RTL layout for Hebrew)
- Event name is the **main title** (bold, colored)
- Course name is the **subtitle** (regular, black)
- Time displayed in Hebrew locale format
- Background color matches priority level

### 2. Event Sections (`lib/widgets/event_section.dart`)

**Purpose:** Group events under a date category header

**Props:**
- `title: String` - Section header (e.g., "היום", "מחר")
- `events: List<MoodleEvent>` - Events in this section
- `priority: EventPriority` - Applied to all cards in section

### 3. Greeting Header (`lib/widgets/greeting_header.dart`)

**Purpose:** Display time-based greeting

**Behavior:**
- Automatically determines greeting based on device time
- Time ranges:
  - 05:00-11:59: "בוקר טוב!" (Good morning)
  - 12:00-16:59: "צהריים טובים!" (Good afternoon)
  - 17:00-20:59: "ערב טוב!" (Good evening)
  - 21:00-04:59: "לילה טוב!" (Good night)
- No bottom padding (sits close to summary text)

### 4. Summary Text (`lib/widgets/summary_text.dart`)

**Purpose:** Show count of deadlines in the next 7 days

**Behavior:**
- Counts events from today through next 7 days
- Hebrew grammar handling:
  - 0 events: "אין מטלות השבוע"
  - 1 event: "יש לך מטלה אחת להגשה השבוע"
  - 2+ events: "יש לך X מטלות להגשה השבוע"

### 5. Shimmer Loading View (`lib/widgets/shimmer_loading_view.dart`)

**Purpose:** Display skeleton loading state during initial data fetch

**Behavior:**
- Shows shimmer skeleton that matches the actual content layout
- Displays 3 sections (Today, Tomorrow, This Week) with skeleton cards
- Each skeleton card matches EventCard dimensions and priority colors
- Uses `shimmer` package for animated gradient effect

### 6. Error State View (`lib/widgets/error_state_view.dart`)

**Purpose:** Display error state with retry functionality

**Props:**
- `errorMessage: String?` - Error message to display
- `onRetry: VoidCallback` - Callback for retry button

**Behavior:**
- Shows large error icon (red)
- Displays localized error message
- Shows technical error details below
- Provides retry button with refresh icon

---

## Business Logic

### Date Categorization (`lib/utils/date_utils.dart`)

Events are grouped into the following categories in order:

1. **היום** (Today) - Events due today
2. **מחר** (Tomorrow) - Events due tomorrow
3. **השבוע** (This Week) - Events in next 2-7 days
4. **שבוע הבא** (Next Week) - Events in days 8-14
5. **החודש** (This Month) - Events within current month
6. **מעל חודש** (Over a Month) - Events beyond current month

**Key Functions:**
- `groupEventsByDate()`: Categorizes events into date buckets
- `getSortedDayKeys()`: Returns categories in display order
- `getPriority()`: Determines priority level for styling

### Event Counting (`lib/utils/event_counter.dart`)

**Definition of "This Week":** Today + next 6 days (total 7 days)

**Functions:**
- `countEventsThisWeek()`: Returns count of events in next 7 days
- `getSummaryText()`: Returns grammatically correct Hebrew string

---

## Data Flow

### Initial Load
```
App Start
    ↓
HomeScreen.initState()
    ↓
_loadDeadlines() → setState(_isLoading = true)
    ↓
ShimmerLoadingView displayed
    ↓
MoodleClient.fetchDeadlines()
    ↓
List<MoodleEvent>
    ↓
setState(_events = data, _isLoading = false)
    ↓
EventDateUtils.groupEventsByDate()
    ↓
Map<String, List<MoodleEvent>>
    ↓
EventSection → EventCard widgets
```

### Pull-to-Refresh
```
User pulls down
    ↓
RefreshIndicator triggers _onRefresh()
    ↓
MoodleClient.fetchDeadlines() (content still visible)
    ↓
setState(_events = new data)
    ↓
UI updates with fresh data
```

### Error Handling
```
Initial Load Error → Full screen error + SnackBar with retry
Refresh Error → Content stays visible + SnackBar with retry
```

---

## State Management

**Current Approach:** StatefulWidget with manual state management

**HomeScreen State:**
- `_moodleClient`: Instance of MoodleClient
- `_isLoading`: Boolean flag for initial load state
- `_events`: Nullable list of MoodleEvent objects
- `_errorMessage`: Nullable string for error handling

**State Flow:**
1. **Initial Load:** `_loadDeadlines()` sets `_isLoading = true`, fetches data, updates `_events`
2. **Pull-to-Refresh:** `_onRefresh()` fetches new data while keeping existing data visible
3. **Error Handling:** Separate flows for initial load errors (full screen) vs refresh errors (SnackBar)

**Why this approach:**
- Simple and effective for current scope
- Direct control over loading and error states
- Supports RefreshIndicator requirements
- No external state management dependencies
- Easy to understand and maintain

**Future Considerations:**
If the app grows in complexity, consider:
- **Provider** for global state (theme, settings)
- **Riverpod** for advanced dependency injection
- **BLoC** for complex business logic flows

---


## Naming Conventions

### Files
- **Snake case:** `event_card.dart`, `date_utils.dart`
- **Descriptive names:** File name should match primary class name

### Classes
- **PascalCase:** `EventCard`, `GreetingHelper`, `MoodleEvent`
- **Suffixes:**
  - `*Helper`: Pure logic utility classes
  - `*Utils`: Utility classes with static methods
  - `*Client`: API/service classes

### Variables
- **camelCase:** `todayEvents`, `formattedTime`, `dayKey`
- **Prefix `_` for private:** `_moodleClient`, `_getColorsForPriority`

### Constants
- **camelCase** (not SCREAMING_SNAKE_CASE): `static const String today = 'היום';`

---

## Code Style Preferences

### 1. **Immutability**
- Use `final` wherever possible
- Use `const` constructors for widgets when applicable
- Example: `const GreetingHeader({Key? key})`

### 2. **Null Safety**
- Always use null-safe types
- Use `!` only when certain value exists
- Prefer `??` operator for defaults

### 3. **Widget Composition**
- Break down complex widgets into smaller components
- Each widget should have a single responsibility
- Extract reusable patterns into separate widgets

### 4. **Comments**
- Use comments for complex logic only
- Prefer self-documenting code
- Add section comments in long widget trees

### 5. **Formatting**
- Follow Dart style guide
- Use `flutter format` before commits
- Max line length: 80 characters (flexible for readability)

---

## Testing Strategy

### Unit Tests
Test business logic in `lib/utils/`:
```dart
// test/utils/greeting_helper_test.dart
test('returns morning greeting at 8 AM', () {
  expect(
    GreetingHelper.getGreeting(DateTime(2024, 1, 1, 8, 0)),
    'בוקר טוב!'
  );
});
```

### Widget Tests
Test individual widgets:
```dart
// test/widgets/event_card_test.dart
testWidgets('EventCard displays event info', (tester) async {
  final event = MoodleEvent(...);
  await tester.pumpWidget(MaterialApp(
    home: EventCard(event: event, priority: EventPriority.high),
  ));
  expect(find.text(event.name), findsOneWidget);
});
```

### Integration Tests
Test complete user flows in `integration_test/`.

---

## Performance Considerations

### Current Optimizations
1. **Const constructors** for static widgets
2. **Stateless widgets** where possible
3. **Efficient list rendering** with `ListView.builder` (future)

### Future Optimizations
1. **Lazy loading:** Use `ListView.builder` if event count grows
2. **Image caching:** If event icons are added
3. **Pagination:** If fetching >100 events
4. **Data caching:** Cache fetched events for offline access

---

## Security Considerations

### Current Implementation
- Token stored in `.env` file (development)
- `.env` excluded from version control via `.gitignore`
- No sensitive data in code

### Production Requirements
- **Use `flutter_secure_storage`** for token storage
- **Implement token refresh** mechanism
- **Add certificate pinning** for API calls
- **Obfuscate code** in production builds

---

## Deployment

### Web
```bash
flutter build web --release
```
Deploy to Firebase Hosting, Netlify, or similar.

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```
Requires Xcode and Apple Developer account.

---

## Future Enhancements

### Planned Features
1. **Event Icons** - Visual indicators (assignment, quiz, lab)
3. **Clickable Cards** - Navigate to Moodle event URL
4. **Filtering** - Filter by course or priority
5. **Calendar View** - Alternative visualization
6. **Background Sync** - Automatic periodic data refresh with workmanager

### Recently Implemented
- ✅ **Dark Mode** - Toggle between light/dark themes
- ✅ **Smart Notifications** - Local reminders for upcoming deadlines
- ✅ **Home Screen Widget** - Quick view without opening app
- ✅ **Pull-to-refresh** - Manual data refresh via gesture
- ✅ **Shimmer Loading** - Skeleton screens during load
- ✅ **Error Handling** - User-friendly error states with retry

### Architecture Changes for Scale
- **State Management:** Add Provider/Riverpod when state complexity grows
- **Repository Pattern:** Abstract data layer for offline support
- **Dependency Injection:** Use GetIt or Riverpod for testability
- **Feature Modules:** Organize by feature instead of layer if app grows

---

## Troubleshooting

### Common Issues

**1. DateUtils Name Conflict**
- Problem: Flutter has a built-in `DateUtils` class
- Solution: Our class is named `EventDateUtils` to avoid conflicts

**2. RTL Layout Issues**
- Problem: Text alignment issues in Hebrew
- Solution: Use `Directionality` widget or set `locale: Locale('he', 'IL')`

**3. Date Formatting**
- Problem: Dates not displaying in Hebrew
- Solution: Ensure `initializeDateFormatting('he_IL', null)` is called in `main()`

**4. Missing Events**
- Problem: Some events not showing
- Solution: Check date grouping logic in `EventDateUtils.groupEventsByDate()`

---

## Contributing Guidelines

### Code Review Checklist
- [ ] No hardcoded strings (use `AppStrings`)
- [ ] No magic numbers (use named constants)
- [ ] Widget names are descriptive
- [ ] Complex logic has comments
- [ ] Code is formatted (`flutter format`)
- [ ] No linter warnings (`flutter analyze`)
- [ ] Tested on both light and dark system themes
- [ ] Tested on different screen sizes

### Commit Message Format
```
type(scope): description

Examples:
feat(ui): add dark mode toggle
fix(date): correct weekly event counting
docs(readme): update installation steps
refactor(widgets): extract common card component
```

---

## Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Material Design 3](https://m3.material.io/)

### Tools
- **Flutter DevTools:** Performance profiling
- **VS Code Extensions:** Flutter, Dart
- **Android Studio:** Full IDE support

---

## Contact & Support

For questions or issues:
1. Check this documentation
2. Review code comments
3. Consult Flutter documentation
4. Create an issue in the repository

---

**Last Updated:** 2025-01-25
**Version:** 1.1.0
**Maintained By:** Development Team
