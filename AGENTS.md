# Repository Guidelines

## Project Structure & Module Organization
This repository is a Flutter kiosk demo. Core app code lives in `lib/`: `main.dart` boots the app, `theme/` holds Material 3 theming, `screens/kiosk/` contains the ordering flow, `models/` and `data/` define state and seed content, and `services/` contains platform-specific helpers such as haptics. Tests live in `test/`. Static assets are declared in `pubspec.yaml` and stored under `images/`, `fonts/`, `Sounds/`, and `Video/`. Platform shells are in `android/`, `ios/`, `macos/`, and `web/`.

## Build, Test, and Development Commands
- `flutter pub get` installs dependencies from `pubspec.yaml`.
- `flutter run` launches the app on the default device.
- `flutter run -d chrome` runs the web build locally.
- `flutter analyze` applies the configured Flutter lints.
- `flutter test` runs widget and unit tests in `test/`.
- `flutter build web` or `flutter build apk` creates production builds.

## Coding Style & Naming Conventions
Follow standard Dart style: 2-space indentation, trailing commas where formatter-friendly, and no manual alignment. Run `dart format lib test` before opening a PR. File names use `snake_case.dart`; classes, enums, and widgets use `PascalCase`; members use `camelCase`. Prefer theme-derived colors and text styles via `Theme.of(context)` rather than hard-coded values. Keep asset paths exact and case-sensitive; this matters for web and Linux-style deployments.

## Testing Guidelines
Use `flutter_test` for widget and logic coverage. Add tests next to the feature area they validate, and name files with the `_test.dart` suffix, for example `test/menu_screen_test.dart`. New work should cover navigation, cart behavior, and pricing logic when touched. The current `test/widget_test.dart` is a starter smoke test and should be replaced or expanded for real feature work.

## Commit & Pull Request Guidelines
Recent history uses short imperative subjects such as `Add welcome screen video...` and `Fix image paths...`; keep that pattern. Limit each commit to one focused change. PRs should include a concise summary, test notes (`flutter analyze`, `flutter test`), linked issue or task if available, and screenshots or screen recordings for UI changes across affected platforms.
