# LifeOS

LifeOS is a Flutter-based personal productivity and life-management app. It brings daily planning, finance tracking, health monitoring, mental wellness, journaling, focus sessions, goals, habits, and profile management into one mobile experience.

Firebase is used as the backend for authentication, cloud data storage, profile image storage, and crash reporting.

## Project Documents

- [QA Report](QA_REPORT.md)
- [Performance Audit Index](PERFORMANCE_AUDIT_INDEX.md)

## Features

- Firebase email/password authentication
- Google Sign-In
- Password reset and password update
- Personalized onboarding flow
- Main dashboard with quick summaries
- Task management with deadlines, priorities, categories, completion status, and reminders
- Finance tracker for income and expenses
- Health tracker for steps, water intake, sleep, and health score
- Health analytics and history
- Mental wellness mood tracking
- Daily journal and gratitude entries
- Focus timer
- Goals and habit tracking with streaks
- Profile editing with profile photo upload
- Notification preferences
- Emergency mode screen
- Light and dark theme support

## Tech Stack

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase Crashlytics
- GetX for routing and state management
- SharedPreferences and Flutter Secure Storage
- Local notifications
- Pedometer integration

## App Structure

- `lib/screen/` - app screens and feature pages
- `lib/controllers/` - GetX controllers
- `lib/services/` - Firebase, storage, notification, and utility services
- `lib/models/` - data models
- `lib/routes/` - app route names and route pages
- `assets/` - images, icons, and certificates
- `test/` - widget and unit tests

## Running The App

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run tests:

```bash
flutter test
```

## Production Build Notes

Provide API runtime config with compile-time defines when needed:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

Build a release APK with obfuscation:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

Crash reporting is wired through Firebase Crashlytics in `lib/main.dart`.

## Deep Linking

- Android App Links intent filter is configured in `android/app/src/main/AndroidManifest.xml`.
- Replace `lifeos.app` with your real domain and publish `assetlinks.json` on the domain.
- iOS Universal Links require an Associated Domains entitlement in the Xcode project settings.

## Navigation

LifeOS uses GetX navigation.

- Route names are defined in `lib/routes/app_routes.dart`
- Route pages are defined in `lib/routes/app_pages.dart`
- Global dependencies are configured in `lib/bindings/app_binding.dart`
- Route middleware is available in `lib/middleware/route_middleware.dart`
