# lifeos

A Flutter app for personal productivity and life management.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Testing

```bash
flutter test
```

## Production Build Notes

- Provide API runtime config via compile-time defines:

```bash
flutter run --dart-define=API_BASE_URL=https://api.example.com
```

- Build release with obfuscation:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

- Crash reporting is wired through Firebase Crashlytics in `lib/main.dart`.

## Deep Linking

- Android App Links intent filter is configured in `android/app/src/main/AndroidManifest.xml`.
- Replace `lifeos.app` with your real domain and publish `assetlinks.json` on the domain.
- iOS Universal Links require an Associated Domains entitlement (not yet configured in Xcode project settings).

## GetX Navigation Conventions

- Use `Get.toNamed(...)` for forward navigation.
- Use `Get.offNamed(...)` / `Get.offAllNamed(...)` when replacing route stacks.
- Use `Get.back()` instead of `Navigator.pop(context)`.
- When a dialog/screen must return a value, use `Get.back(result: value)`.

## Routing Structure

- Route names: `lib/routes/app_routes.dart`
- Route pages: `lib/routes/app_pages.dart`
- Global binding scaffold: `lib/bindings/app_binding.dart`
- Route middleware scaffold: `lib/middleware/route_middleware.dart`

The middleware is currently pass-through (logs route names) and is ready for future auth/guard logic.
