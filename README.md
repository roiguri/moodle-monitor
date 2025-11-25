# Moodle Monitor

A modern Flutter application for viewing Moodle assignment deadlines with a beautiful, priority-based interface.

## Features

- 🎨 **Priority-Based Design**: Color-coded cards (red for today, yellow for tomorrow, blue for future)
- 🕐 **Time-Based Greetings**: Personalized Hebrew greetings based on time of day
- 📊 **Smart Categorization**: Events grouped by היום, מחר, השבוע, שבוע הבא, החודש, מעל חודש
- 📱 **Cross-Platform**: Works on Android, iOS, and Web
- 🌍 **Localization-Ready**: Prepared for multi-language support
- 🎯 **Material Design 3**: Modern, clean UI following Material guidelines

## Getting Started

### Prerequisites

- Flutter SDK (≥3.0.0)
- Dart SDK (≥3.0.0)
- A Moodle account with API access

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd moodle-monitor
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables:**

   Create a `.env` file in the root directory:
   ```env
   MOODLE_TOKEN=your_moodle_api_token
   MOODLE_URL=https://your-moodle-instance.com
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

### Getting Your Moodle API Token

1. Log in to your Moodle instance
2. Go to: Profile → Preferences → Security Keys
3. Create a new service token
4. Copy the token to your `.env` file

## Architecture

This project follows a feature-based architecture with clear separation of concerns:

```
lib/
├── constants/     # Colors, strings, text styles
├── models/        # Data structures
├── services/      # API clients
├── utils/         # Business logic
├── widgets/       # Reusable UI components
└── screens/       # Top-level pages
```

For detailed architecture documentation, see [ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Project Structure

- **Constants** (`lib/constants/`): Centralized styling and strings
- **Models** (`lib/models/`): Data models (MoodleEvent)
- **Services** (`lib/services/`): Moodle API integration
- **Utils** (`lib/utils/`): Business logic (date grouping, event counting, greetings)
- **Widgets** (`lib/widgets/`): Reusable components (EventCard, GreetingHeader)
- **Screens** (`lib/screens/`): Main application screens

## Development

### Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` before committing
- Run `flutter analyze` to check for issues

### Adding New Strings

Add all user-facing strings to `lib/constants/app_strings.dart`:
```dart
static const String newString = 'תרגום בעברית';
```

### Color Scheme

Colors are defined in `lib/constants/app_colors.dart`:
- **High Priority (Today)**: Pastel Red (#EF5350)
- **Medium Priority (Tomorrow)**: Pastel Yellow (#FFCA28)
- **Low Priority (Future)**: Pastel Blue (#64B5F6)

## Building for Production

### Android
```bash
flutter build apk --release
# or for Google Play
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Roadmap

- [ ] Dark mode support
- [ ] English localization
- [ ] Event icons (assignment, quiz, lab)
- [ ] Click to open event in browser
- [ ] Pull-to-refresh
- [ ] Filtering by course
- [ ] Calendar view
- [ ] Push notifications
- [ ] Home screen widget

## Known Issues

See the [issues page](../../issues) for known bugs and planned enhancements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Uses [Moodle Web Services API](https://docs.moodle.org/dev/Web_services)
- Icons from [Material Symbols](https://fonts.google.com/icons)

## Support

For questions or issues:
1. Check [ARCHITECTURE.md](docs/ARCHITECTURE.md)
2. Search existing issues
3. Create a new issue with details

---

**Made with ❤️ using Flutter**
